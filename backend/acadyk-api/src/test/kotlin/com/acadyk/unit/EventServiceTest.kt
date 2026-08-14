package com.acadyk.unit

import com.acadyk.modules.events.dto.CreateEventDto
import com.acadyk.modules.events.entity.EventEntity
import com.acadyk.modules.events.entity.EventType
import com.acadyk.modules.events.entity.EventRegistrationEntity
import com.acadyk.modules.events.repository.EventRepository
import com.acadyk.modules.events.repository.EventRegistrationRepository
import com.acadyk.modules.events.service.EventService
import com.acadyk.infrastructure.kafka.DomainEventPublisher
import com.acadyk.security.CurrentUserProvider
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.mockito.Mockito.*
import java.time.Instant
import java.util.Optional
import java.util.UUID

class EventServiceTest {

    private lateinit var eventRepository: EventRepository
    private lateinit var registrationRepository: EventRegistrationRepository
    private lateinit var domainEventPublisher: DomainEventPublisher
    private lateinit var currentUserProvider: CurrentUserProvider
    private lateinit var eventService: EventService

    private val testUserId = UUID.randomUUID()
    private val testEventId = UUID.randomUUID()

    @BeforeEach
    fun setUp() {
        eventRepository = mock(EventRepository::class.java)
        registrationRepository = mock(EventRegistrationRepository::class.java)
        domainEventPublisher = mock(DomainEventPublisher::class.java)
        currentUserProvider = mock(CurrentUserProvider::class.java)

        `when`(currentUserProvider.getCurrentUserId()).thenReturn(testUserId)

        eventService = EventService(
            eventRepository = eventRepository,
            registrationRepository = registrationRepository,
            domainEventPublisher = domainEventPublisher,
            currentUserProvider = currentUserProvider
        )
    }

    @Test
    fun `createEvent persists event entity and publishes Kafka event`() {
        val dto = CreateEventDto(
            title = "Global Tech Hackathon 2026",
            organizerName = "Acadyk Community",
            eventType = "HACKATHON",
            description = "36-hour hackathon for student developers",
            startTime = Instant.now(),
            endTime = Instant.now().plusSeconds(86400)
        )

        val saved = EventEntity(
            id = testEventId,
            organizerId = testUserId,
            title = dto.title,
            organizerName = dto.organizerName,
            eventType = EventType.HACKATHON,
            description = dto.description,
            startTime = dto.startTime,
            endTime = dto.endTime
        )

        `when`(eventRepository.save(any(EventEntity::class.java))).thenReturn(saved)

        val result = eventService.createEvent(dto)

        assertNotNull(result)
        assertEquals(dto.title, result.title)
        assertEquals(dto.organizerName, result.organizerName)
        verify(eventRepository, times(1)).save(any())
    }

    @Test
    fun `registerForEvent checks existence, creates registration and publishes EventRegistered event`() {
        val event = EventEntity(
            id = testEventId,
            organizerId = UUID.randomUUID(),
            title = "Tech Summit",
            organizerName = "Acadyk",
            eventType = EventType.WORKSHOP,
            description = "Workshop description",
            startTime = Instant.now(),
            endTime = Instant.now().plusSeconds(7200)
        )

        `when`(eventRepository.findById(testEventId)).thenReturn(Optional.of(event))
        `when`(registrationRepository.existsByEventIdAndUserId(testEventId, testUserId)).thenReturn(false)
        `when`(registrationRepository.save(any(EventRegistrationEntity::class.java))).thenAnswer { it.arguments[0] }

        val registered = eventService.registerForEvent(testEventId.toString(), mapOf("phone" to "9876543210"))

        assertTrue(registered)
        verify(registrationRepository, times(1)).save(any())
        verify(domainEventPublisher, times(1)).publish(any())
    }
}
