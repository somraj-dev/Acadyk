package com.acadyk.modules.connections.service

import com.acadyk.common.BadRequestException
import com.acadyk.common.ResourceNotFoundException
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
        if (currentUserId == request.recipientId) {
            throw BadRequestException("Cannot connect with yourself")
        }

        val sender = profileRepository.findById(currentUserId)
            .orElseThrow { ResourceNotFoundException("Sender profile not found") }
        val recipient = profileRepository.findById(request.recipientId)
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

    fun acceptConnectionRequest(requestId: String) {
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
                userAId = request.sender.id,
                userBId = request.recipient.id,
                userAName = request.sender.fullName
            )
        )
    }

    fun removeConnection(connectionId: String) {
        connectionRepository.deleteById(connectionId)
    }

    fun toggleFollow(targetUserId: String): FollowStatusResponse {
        val currentUserId = currentUserProvider.getCurrentUserId()
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

        return FollowStatusResponse(targetUserId, isFollowing)
    }

    @Transactional(readOnly = true)
    fun getFollowers(userId: String): List<ProfileResponse> =
        followRepository.findAllByFollowingId(userId).map { profileMapper.toResponse(it.follower) }

    @Transactional(readOnly = true)
    fun getFollowing(userId: String): List<ProfileResponse> =
        followRepository.findAllByFollowerId(userId).map { profileMapper.toResponse(it.following) }
}
