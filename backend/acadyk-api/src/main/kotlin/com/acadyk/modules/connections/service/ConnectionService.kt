package com.acadyk.modules.connections.service

import com.acadyk.common.BadRequestException
import com.acadyk.common.ResourceNotFoundException
import com.acadyk.common.toUUID
import com.acadyk.infrastructure.kafka.ConnectionCreatedEvent
import com.acadyk.infrastructure.kafka.DomainEventPublisher
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
    private val connectionMapper: ConnectionMapper,
    private val profileMapper: ProfileMapper,
    private val currentUserProvider: CurrentUserProvider,
    private val domainEventPublisher: DomainEventPublisher
) {

    fun sendConnectionRequest(request: SendConnectionRequest): ConnectionRequestResponse {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val recipientUuid = request.recipientId.toUUID()
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
        connectionRepository.deleteById(connectionId)
    }

    fun removeConnection(connectionId: String) = removeConnection(connectionId.toUUID())

    fun toggleFollow(targetUserId: UUID): FollowStatusResponse {
        val currentUserId = currentUserProvider.getCurrentUserId()
        if (currentUserId == targetUserId) {
            throw BadRequestException("Users cannot follow themselves")
        }

        val existing = followRepository.findByFollowerIdAndFollowingId(currentUserId, targetUserId)

        val targetUser = profileRepository.findById(targetUserId)
            .orElseThrow { ResourceNotFoundException("Target profile not found") }
        val currentUser = profileRepository.findById(currentUserId)
            .orElseThrow { ResourceNotFoundException("Current profile not found") }

        val isFollowing: Boolean

        if (existing.isPresent) {
            followRepository.delete(existing.get())
            currentUser.followingCount = maxOf(0, currentUser.followingCount - 1)
            targetUser.followersCount = maxOf(0, targetUser.followersCount - 1)
            isFollowing = false
        } else {
            followRepository.save(FollowEntity(follower = currentUser, following = targetUser))
            currentUser.followingCount += 1
            targetUser.followersCount += 1
            isFollowing = true
        }

        profileRepository.save(currentUser)
        profileRepository.save(targetUser)

        return FollowStatusResponse(targetUserId.toString(), isFollowing)
    }

    fun toggleFollow(targetUserId: String): FollowStatusResponse = toggleFollow(targetUserId.toUUID())

    @Transactional(readOnly = true)
    fun getFollowers(userId: UUID): List<ProfileResponse> =
        followRepository.findAllByFollowingId(userId).map { profileMapper.toResponse(it.follower) }

    @Transactional(readOnly = true)
    fun getFollowers(userId: String): List<ProfileResponse> = getFollowers(userId.toUUID())

    @Transactional(readOnly = true)
    fun getFollowing(userId: UUID): List<ProfileResponse> =
        followRepository.findAllByFollowerId(userId).map { profileMapper.toResponse(it.following) }

    @Transactional(readOnly = true)
    fun getFollowing(userId: String): List<ProfileResponse> = getFollowing(userId.toUUID())
}
