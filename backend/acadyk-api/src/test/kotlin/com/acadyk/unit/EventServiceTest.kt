package com.acadyk.unit

import com.acadyk.infrastructure.kafka.DomainEventPublisher
import com.acadyk.infrastructure.redis.RedisDistributedLock
import com.acadyk.modules.events.dto.CreateEventRequest
import com.acadyk.modules.events.entity.EventEntity
import com.acadyk.modules.events.entity.EventRegistrationEntity
import com.acadyk.modules.events.mapper.EventMapper
import com.acadyk.modules.events.repository.EventRegistrationRepository
import com.acadyk.modules.events.repository.EventRepository
import com.acadyk.modules.events.service.EventService
import com.acadyk.modules.profiles.entity.ProfileEntity
import com.acadyk.modules.profiles.repository.ProfileRepository
import com.acadyk.security.CurrentUserProvider
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import org.mockito.Mockito.*
import org.springframework.data.redis.core.RedisTemplate
import org.springframework.data.redis.core.ValueOperations
import java.time.Instant
import java.util.Optional
import java.util.UUID

class EventServiceTest {

    private lateinit var eventRepository: EventRepository
    private lateinit var registrationRepository: EventRegistrationRepository
    private lateinit var profileRepository: ProfileRepository
    private lateinit var eventMapper: EventMapper
    private lateinit var currentUserProvider: CurrentUserProvider
    private lateinit var domainEventPublisher: DomainEventPublisher
    private lateinit var redisTemplate: RedisTemplate<String, Any>
    private lateinit var redisDistributedLock: RedisDistributedLock
    private lateinit var eventService: EventService

    private val testUserId: UUID = UUID.randomUUID()
    private val testEventId: UUID = UUID.randomUUID()

    @Suppress("UNCHECKED_CAST")
    private fun <T> anyNonNull(): T {
        Mockito.any<T>()
        return null as T
    }

    @BeforeEach
    fun setUp() {
        eventRepository = mock(EventRepository::class.java)
        registrationRepository = mock(EventRegistrationRepository::class.java)
        profileRepository = mock(ProfileRepository::class.java)
        eventMapper = EventMapper()
        currentUserProvider = mock(CurrentUserProvider::class.java)
        domainEventPublisher = mock(DomainEventPublisher::class.java)

        @Suppress("UNCHECKED_CAST")
        redisTemplate = mock(RedisTemplate::class.java) as RedisTemplate<String, Any>
        @Suppress("UNCHECKED_CAST")
        val valueOps = mock(ValueOperations::class.java) as ValueOperations<String, Any>
        `when`(redisTemplate.opsForValue()).thenReturn(valueOps)
        `when`(valueOps.setIfAbsent(anyNonNull(), anyNonNull(), anyNonNull())).thenReturn(true)
        redisDistributedLock = RedisDistributedLock(redisTemplate)

        `when`(currentUserProvider.getCurrentUserId()).thenReturn(testUserId)

        eventService = EventService(
            eventRepository = eventRepository,
            eventRegistrationRepository = registrationRepository,
            profileRepository = profileRepository,
            eventMapper = eventMapper,
            currentUserProvider = currentUserProvider,
            domainEventPublisher = domainEventPublisher,
            redisDistributedLock = redisDistributedLock
        )
    }

    @Test
    fun `createEvent persists event entity and returns response`() {
        val organizer = ProfileEntity(
            id = testUserId,
            username = "organizer",
            email = "organizer@acadyk.com",
            fullName = "Acadyk Community"
        )

        val request = CreateEventRequest(
            title = "Global Tech Hackathon 2026",
            eventType = "HACKATHON",
            description = "36-hour hackathon for student developers",
            startTime = Instant.now(),
            endTime = Instant.now().plusSeconds(86400)
        )

        val saved = EventEntity(
            id = testEventId,
            organizer = organizer,
            title = request.title,
            slug = "global-tech-hackathon-2026-1234",
            eventType = request.eventType ?: "HACKATHON",
            description = request.description,
            startTime = request.startTime ?: Instant.now(),
            endTime = request.endTime
        )

        `when`(profileRepository.findById(testUserId)).thenReturn(Optional.of(organizer))
        `when`(eventRepository.save(anyNonNull())).thenReturn(saved)

        val result = eventService.createEvent(request)

        assertNotNull(result)
        assertEquals(request.title, result.title)
        assertEquals(organizer.fullName, result.organizerName)
        verify(eventRepository, times(1)).save(anyNonNull())
    }

    @Test
    fun `registerForEvent checks existence, creates registration and publishes EventRegistered event`() {
        val organizer = ProfileEntity(id = UUID.randomUUID(), username = "org", email = "org@acadyk.com", fullName = "Acadyk")
        val user = ProfileEntity(id = testUserId, username = "user1", email = "user@acadyk.com", fullName = "Somraj")

        val event = EventEntity(
            id = testEventId,
            organizer = organizer,
            title = "Tech Summit",
            slug = "tech-summit-1234",
            eventType = "WORKSHOP",
            description = "Workshop description",
            startTime = Instant.now(),
            endTime = Instant.now().plusSeconds(7200)
        )

        `when`(eventRepository.findByIdAndDeletedAtIsNull(testEventId)).thenReturn(Optional.of(event))
        `when`(profileRepository.findById(testUserId)).thenReturn(Optional.of(user))
        `when`(registrationRepository.existsByEventIdAndProfileId(testEventId, testUserId)).thenReturn(false)
        `when`(registrationRepository.save(anyNonNull())).thenAnswer {
            EventRegistrationEntity(id = UUID.randomUUID(), event = event, profile = user)
        }

        val registered = eventService.registerForEvent(testEventId)

        assertTrue(registered)
        verify(registrationRepository, times(1)).save(anyNonNull())
        verify(domainEventPublisher, times(1)).publishEventRegistered(anyNonNull())
    }
}
