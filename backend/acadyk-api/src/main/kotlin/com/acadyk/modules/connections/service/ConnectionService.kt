package com.acadyk.modules.connections.service

import com.acadyk.common.BadRequestException
import com.acadyk.common.ForbiddenException
import com.acadyk.common.ResourceNotFoundException
import com.acadyk.common.toUUID
import com.acadyk.infrastructure.kafka.ConnectionCreatedEvent
import com.acadyk.infrastructure.kafka.DomainEventPublisher
import com.acadyk.infrastructure.kafka.FollowEvent
import com.acadyk.modules.connections.dto.ConnectionRequestResponse
import com.acadyk.modules.connections.dto.FollowStatusResponse
import com.acadyk.modules.connections.dto.SendConnectionRequest
import com.acadyk.modules.connections.entity.ConnectionEntity
import com.acadyk.modules.connections.entity.ConnectionRequestEntity
import com.acadyk.modules.connections.entity.FollowEntity
import com.acadyk.modules.connections.mapper.ConnectionMapper
import com.acadyk.modules.connections.repository.ConnectionRepository
import com.acadyk.modules.connections.repository.ConnectionRequestRepository
import com.acadyk.modules.connections.repository.FollowRepository
import com.acadyk.modules.profiles.dto.ProfileResponse
import com.acadyk.modules.profiles.mapper.ProfileMapper
import com.acadyk.modules.profiles.repository.ProfileRepository
import com.acadyk.security.CurrentUserProvider
import com.acadyk.common.toUUIDOrNull
import com.acadyk.modules.users.repository.UserRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.util.UUID

@Service
@Transactional
class ConnectionService(
    private val connectionRepository: ConnectionRepository,
    private val connectionRequestRepository: ConnectionRequestRepository,
    private val followRepository: FollowRepository,
    private val profileRepository: ProfileRepository,
    private val userRepository: UserRepository,
    private val connectionMapper: ConnectionMapper,
    private val profileMapper: ProfileMapper,
    private val currentUserProvider: CurrentUserProvider,
    private val domainEventPublisher: DomainEventPublisher
) {

    fun resolveProfileId(identifier: String): UUID {
        val trimmed = identifier.trim()
        if (trimmed.equals("me", ignoreCase = true) || trimmed.equals("self", ignoreCase = true)) {
            return currentUserProvider.getCurrentUserId()
        }

        // 1. Direct UUID match
        val directUuid = trimmed.toUUIDOrNull()
        if (directUuid != null) {
            if (profileRepository.existsById(directUuid)) {
                return directUuid
            }
            val byUserId = profileRepository.findByUserId(directUuid)
            if (byUserId.isPresent) {
                return byUserId.get().id
            }
            return directUuid
        }

        // 2. Firebase UID match
        val byFirebase = userRepository.findByFirebaseUid(trimmed)
        if (byFirebase.isPresent) {
            val userProfile = profileRepository.findByUserId(byFirebase.get().id)
            if (userProfile.isPresent) return userProfile.get().id
            return byFirebase.get().id
        }

        // 3. Enrollment number match
        val byEnrollment = userRepository.findByEnrollmentNumber(trimmed)
        if (byEnrollment.isPresent) {
            val userProfile = profileRepository.findByUserId(byEnrollment.get().id)
            if (userProfile.isPresent) return userProfile.get().id
            return byEnrollment.get().id
        }

        // 4. Username match
        val byUsername = profileRepository.findByUsername(trimmed)
        if (byUsername.isPresent) {
            return byUsername.get().id
        }

        // 5. Email match
        val byEmail = userRepository.findByEmail(trimmed)
            .or { userRepository.findByCollegeEmail(trimmed) }
        if (byEmail.isPresent) {
            val userProfile = profileRepository.findByUserId(byEmail.get().id)
            if (userProfile.isPresent) return userProfile.get().id
            return byEmail.get().id
        }

        // 6. Handle mock-firebase-uid- prefix in dev mode
        val cleanPrefix = trimmed.removePrefix("mock-firebase-uid-").trim()
        if (cleanPrefix != trimmed) {
            val byClean = userRepository.findByEmail("$cleanPrefix@mitsgwl.ac.in")
                .or { userRepository.findByCollegeEmail("$cleanPrefix@mitsgwl.ac.in") }
                .or { userRepository.findByEnrollmentNumber(cleanPrefix) }
            if (byClean.isPresent) {
                val userProfile = profileRepository.findByUserId(byClean.get().id)
                if (userProfile.isPresent) return userProfile.get().id
                return byClean.get().id
            }
        }

        throw ResourceNotFoundException("Profile identity could not be resolved for: $identifier")
    }

    fun sendConnectionRequest(request: SendConnectionRequest): ConnectionRequestResponse {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val recipientUuid = resolveProfileId(request.recipientId)
        if (currentUserId == recipientUuid) {
            throw BadRequestException("Cannot connect with yourself")
        }

        val sender = profileRepository.findById(currentUserId)
            .orElseThrow { ResourceNotFoundException("Sender profile not found") }
        val recipient = profileRepository.findById(recipientUuid)
            .orElseThrow { ResourceNotFoundException("Recipient profile not found") }

        val connRequest = connectionRequestRepository.save(
            ConnectionRequestEntity(
                sender = sender,
                recipient = recipient,
                message = request.message
            )
        )

        return connectionMapper.toResponse(connRequest)
    }

    fun acceptConnectionRequest(requestId: UUID) {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val request = connectionRequestRepository.findById(requestId)
            .orElseThrow { ResourceNotFoundException("Connection request not found") }

        if (request.recipient.id != currentUserId) {
            throw BadRequestException("Cannot accept a request not addressed to you")
        }

        request.status = "ACCEPTED"
        request.respondedAt = Instant.now()
        connectionRequestRepository.save(request)

        connectionRepository.save(ConnectionEntity(userA = request.sender, userB = request.recipient))

        request.sender.connectionsCount += 1
        request.recipient.connectionsCount += 1
        profileRepository.save(request.sender)
        profileRepository.save(request.recipient)

        domainEventPublisher.publishConnectionCreated(
            ConnectionCreatedEvent(
                userAId = request.sender.id.toString(),
                userBId = request.recipient.id.toString(),
                userAName = request.sender.fullName
            )
        )
    }

    fun acceptConnectionRequest(requestId: String) = acceptConnectionRequest(requestId.toUUID())

    fun removeConnection(connectionId: UUID) {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val connection = connectionRepository.findById(connectionId)
            .orElseThrow { ResourceNotFoundException("Connection not found") }

        if (connection.userA.id != currentUserId && connection.userB.id != currentUserId) {
            throw ForbiddenException("You are not authorized to remove this connection")
        }

        connectionRepository.delete(connection)
    }

    fun removeConnection(connectionId: String) = removeConnection(connectionId.toUUID())

    fun follow(targetUserId: UUID): FollowStatusResponse {
        val currentUserId = currentUserProvider.getCurrentUserId()
        if (currentUserId == targetUserId) {
            throw BadRequestException("Users cannot follow themselves")
        }

        val existing = followRepository.findByFollowerIdAndFollowingId(currentUserId, targetUserId)
        if (existing.isPresent) {
            return FollowStatusResponse(targetUserId.toString(), true)
        }

        val targetUser = profileRepository.findById(targetUserId)
            .orElseThrow { ResourceNotFoundException("Target profile not found") }
        val currentUser = profileRepository.findById(currentUserId)
            .orElseThrow { ResourceNotFoundException("Current profile not found") }

        followRepository.save(FollowEntity(follower = currentUser, following = targetUser))
        currentUser.followingCount += 1
        targetUser.followersCount += 1

        profileRepository.save(currentUser)
        profileRepository.save(targetUser)

        domainEventPublisher.publishFollowEvent(
            FollowEvent(
                followerId = currentUser.id.toString(),
                followerName = currentUser.fullName,
                followingId = targetUser.id.toString()
            )
        )

        return FollowStatusResponse(targetUserId.toString(), true)
    }

    fun follow(targetUserId: String): FollowStatusResponse = follow(resolveProfileId(targetUserId))

    fun unfollow(targetUserId: UUID): FollowStatusResponse {
        val currentUserId = currentUserProvider.getCurrentUserId()
        if (currentUserId == targetUserId) {
            throw BadRequestException("Users cannot unfollow themselves")
        }

        val existing = followRepository.findByFollowerIdAndFollowingId(currentUserId, targetUserId)
        if (existing.isEmpty) {
            return FollowStatusResponse(targetUserId.toString(), false)
        }

        val targetUser = profileRepository.findById(targetUserId)
            .orElseThrow { ResourceNotFoundException("Target profile not found") }
        val currentUser = profileRepository.findById(currentUserId)
            .orElseThrow { ResourceNotFoundException("Current profile not found") }

        followRepository.delete(existing.get())
        currentUser.followingCount = maxOf(0, currentUser.followingCount - 1)
        targetUser.followersCount = maxOf(0, targetUser.followersCount - 1)

        profileRepository.save(currentUser)
        profileRepository.save(targetUser)

        return FollowStatusResponse(targetUserId.toString(), false)
    }

    fun unfollow(targetUserId: String): FollowStatusResponse = unfollow(resolveProfileId(targetUserId))

    fun toggleFollow(targetUserId: UUID): FollowStatusResponse {
        val currentUserId = currentUserProvider.getCurrentUserId()
        if (currentUserId == targetUserId) {
            throw BadRequestException("Users cannot follow themselves")
        }

        val existing = followRepository.findByFollowerIdAndFollowingId(currentUserId, targetUserId)
        return if (existing.isPresent) {
            unfollow(targetUserId)
        } else {
            follow(targetUserId)
        }
    }

    fun toggleFollow(targetUserId: String): FollowStatusResponse = toggleFollow(resolveProfileId(targetUserId))

    @Transactional(readOnly = true)
    fun getFollowers(userId: UUID): List<ProfileResponse> {
        val currentUserId = runCatching { currentUserProvider.getCurrentUserId() }.getOrNull()
        return followRepository.findAllByFollowingId(userId).map {
            val isFollowing = currentUserId?.let { cur -> followRepository.existsByFollowerIdAndFollowingId(cur, it.follower.id) } ?: false
            profileMapper.toResponse(it.follower, isFollowing = isFollowing)
        }
    }

    @Transactional(readOnly = true)
    fun getFollowers(userId: String): List<ProfileResponse> = getFollowers(resolveProfileId(userId))

    @Transactional(readOnly = true)
    fun getFollowing(userId: UUID): List<ProfileResponse> {
        val currentUserId = runCatching { currentUserProvider.getCurrentUserId() }.getOrNull()
        return followRepository.findAllByFollowerId(userId).map {
            val isFollowing = currentUserId?.let { cur -> followRepository.existsByFollowerIdAndFollowingId(cur, it.following.id) } ?: false
            profileMapper.toResponse(it.following, isFollowing = isFollowing)
        }
    }

    @Transactional(readOnly = true)
    fun getFollowing(userId: String): List<ProfileResponse> = getFollowing(resolveProfileId(userId))
}
