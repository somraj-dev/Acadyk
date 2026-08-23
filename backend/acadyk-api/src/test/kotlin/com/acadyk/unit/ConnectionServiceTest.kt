package com.acadyk.unit

import com.acadyk.common.BadRequestException
import com.acadyk.infrastructure.kafka.DomainEventPublisher
import com.acadyk.modules.connections.entity.FollowEntity
import com.acadyk.modules.connections.mapper.ConnectionMapper
import com.acadyk.modules.connections.repository.ConnectionRepository
import com.acadyk.modules.connections.repository.ConnectionRequestRepository
import com.acadyk.modules.connections.repository.FollowRepository
import com.acadyk.modules.connections.service.ConnectionService
import com.acadyk.modules.profiles.entity.ProfileEntity
import com.acadyk.modules.profiles.mapper.ProfileMapper
import com.acadyk.modules.profiles.repository.ProfileRepository
import com.acadyk.security.CurrentUserProvider
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import org.mockito.Mockito.*
import java.util.Optional
import java.util.UUID

class ConnectionServiceTest {

    private lateinit var connectionRepository: ConnectionRepository
    private lateinit var connectionRequestRepository: ConnectionRequestRepository
    private lateinit var followRepository: FollowRepository
    private lateinit var profileRepository: ProfileRepository
    private lateinit var userRepository: com.acadyk.modules.users.repository.UserRepository
    private lateinit var connectionMapper: ConnectionMapper
    private lateinit var profileMapper: ProfileMapper
    private lateinit var currentUserProvider: CurrentUserProvider
    private lateinit var domainEventPublisher: DomainEventPublisher
    private lateinit var connectionService: ConnectionService

    private val currentUserId: UUID = UUID.randomUUID()
    private val targetUserId: UUID = UUID.randomUUID()

    @Suppress("UNCHECKED_CAST")
    private fun <T> anyNonNull(): T {
        org.mockito.Mockito.any<T>()
        return null as T
    }

    @BeforeEach
    fun setUp() {
        connectionRepository = mock(ConnectionRepository::class.java)
        connectionRequestRepository = mock(ConnectionRequestRepository::class.java)
        followRepository = mock(FollowRepository::class.java)
        profileRepository = mock(ProfileRepository::class.java)
        userRepository = mock(com.acadyk.modules.users.repository.UserRepository::class.java)
        connectionMapper = ConnectionMapper(ProfileMapper())
        profileMapper = ProfileMapper()
        currentUserProvider = mock(CurrentUserProvider::class.java)
        domainEventPublisher = mock(DomainEventPublisher::class.java)

        `when`(currentUserProvider.getCurrentUserId()).thenReturn(currentUserId)

        connectionService = ConnectionService(
            connectionRepository = connectionRepository,
            connectionRequestRepository = connectionRequestRepository,
            followRepository = followRepository,
            profileRepository = profileRepository,
            userRepository = userRepository,
            connectionMapper = connectionMapper,
            profileMapper = profileMapper,
            currentUserProvider = currentUserProvider,
            domainEventPublisher = domainEventPublisher
        )
    }

    @Test
    fun `follow saves follow entity, updates counters, and publishes FollowEvent`() {
        val currentUser = ProfileEntity(id = currentUserId, username = "userA", email = "a@acadyk.com", fullName = "User A")
        val targetUser = ProfileEntity(id = targetUserId, username = "userB", email = "b@acadyk.com", fullName = "User B")

        `when`(followRepository.findByFollowerIdAndFollowingId(currentUserId, targetUserId)).thenReturn(Optional.empty())
        `when`(profileRepository.findById(targetUserId)).thenReturn(Optional.of(targetUser))
        `when`(profileRepository.findById(currentUserId)).thenReturn(Optional.of(currentUser))

        val result = connectionService.follow(targetUserId)

        assertTrue(result.isFollowing)
        assertEquals(targetUserId.toString(), result.targetUserId)
        assertEquals(1, currentUser.followingCount)
        assertEquals(1, targetUser.followersCount)
        verify(followRepository, times(1)).save(anyNonNull())
        verify(domainEventPublisher, times(1)).publishFollowEvent(anyNonNull())
    }

    @Test
    fun `follow throws BadRequestException on self follow attempt`() {
        assertThrows<BadRequestException> {
            connectionService.follow(currentUserId)
        }
    }

    @Test
    fun `unfollow removes entity and decrements counters`() {
        val currentUser = ProfileEntity(id = currentUserId, username = "userA", email = "a@acadyk.com", fullName = "User A", followingCount = 1)
        val targetUser = ProfileEntity(id = targetUserId, username = "userB", email = "b@acadyk.com", fullName = "User B", followersCount = 1)
        val followEntity = FollowEntity(follower = currentUser, following = targetUser)

        `when`(followRepository.findByFollowerIdAndFollowingId(currentUserId, targetUserId)).thenReturn(Optional.of(followEntity))
        `when`(profileRepository.findById(targetUserId)).thenReturn(Optional.of(targetUser))
        `when`(profileRepository.findById(currentUserId)).thenReturn(Optional.of(currentUser))

        val result = connectionService.unfollow(targetUserId)

        assertFalse(result.isFollowing)
        assertEquals(0, currentUser.followingCount)
        assertEquals(0, targetUser.followersCount)
        verify(followRepository, times(1)).delete(followEntity)
    }

    @Test
    fun `getFollowers returns followers list mapped to ProfileResponse`() {
        val follower = ProfileEntity(id = currentUserId, username = "userA", email = "a@acadyk.com", fullName = "User A")
        val following = ProfileEntity(id = targetUserId, username = "userB", email = "b@acadyk.com", fullName = "User B")
        val followEntity = FollowEntity(follower = follower, following = following)

        `when`(followRepository.findAllByFollowingId(targetUserId)).thenReturn(listOf(followEntity))

        val followers = connectionService.getFollowers(targetUserId)

        assertEquals(1, followers.size)
        assertEquals("User A", followers[0].fullName)
    }
}
