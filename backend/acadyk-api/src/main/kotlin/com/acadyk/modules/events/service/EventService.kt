package com.acadyk.modules.events.service

import com.acadyk.common.BadRequestException
import com.acadyk.common.PageResponse
import com.acadyk.common.ResourceNotFoundException
import com.acadyk.common.toUUID
import com.acadyk.infrastructure.kafka.DomainEventPublisher
import com.acadyk.infrastructure.kafka.EventRegisteredEvent
import com.acadyk.infrastructure.redis.RedisDistributedLock
import com.acadyk.modules.events.dto.CreateEventRequest
import com.acadyk.modules.events.dto.EventResponse
import com.acadyk.modules.events.entity.EventEntity
import com.acadyk.modules.events.entity.EventRegistrationEntity
import com.acadyk.modules.events.mapper.EventMapper
import com.acadyk.modules.events.repository.EventRegistrationRepository
import com.acadyk.modules.events.repository.EventRepository
import com.acadyk.modules.profiles.repository.ProfileRepository
import com.acadyk.security.CurrentUserProvider
import org.springframework.data.domain.PageRequest
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.util.UUID

@Service
@Transactional
class EventService(
    private val eventRepository: EventRepository,
    private val eventRegistrationRepository: EventRegistrationRepository,
    private val profileRepository: ProfileRepository,
    private val eventMapper: EventMapper,
    private val currentUserProvider: CurrentUserProvider,
    private val domainEventPublisher: DomainEventPublisher,
    private val redisDistributedLock: RedisDistributedLock
) {

    @Transactional(readOnly = true)
    fun getEvents(eventType: String?, page: Int, size: Int): PageResponse<EventResponse> {
        val pageable = PageRequest.of(page, size)
        val currentUserId = try { currentUserProvider.getCurrentUserId() } catch (_: Exception) { null }

        val pageResult = if (!eventType.isNullOrBlank()) {
            eventRepository.findAllByEventTypeAndDeletedAtIsNullOrderByStartTimeDesc(eventType, pageable)
        } else {
            eventRepository.findAllByDeletedAtIsNullOrderByStartTimeDesc(pageable)
        }

        return PageResponse.from(pageResult) { event ->
            val isRegistered = currentUserId?.let { eventRegistrationRepository.existsByEventIdAndProfileId(event.id, it) } ?: false
            eventMapper.toResponse(event, isRegistered)
        }
    }

    @Transactional(readOnly = true)
    fun getEventById(id: UUID): EventResponse {
        val event = eventRepository.findByIdAndDeletedAtIsNull(id)
            .orElseThrow { ResourceNotFoundException("Event with id $id not found") }
        val currentUserId = try { currentUserProvider.getCurrentUserId() } catch (_: Exception) { null }
        val isRegistered = currentUserId?.let { eventRegistrationRepository.existsByEventIdAndProfileId(event.id, it) } ?: false
        return eventMapper.toResponse(event, isRegistered)
    }

    @Transactional(readOnly = true)
    fun getEventById(id: String): EventResponse = getEventById(id.toUUID())

    fun createEvent(request: CreateEventRequest): EventResponse {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val organizer = profileRepository.findById(currentUserId)
            .orElseThrow { ResourceNotFoundException("Organizer profile not found") }

        val slug = request.title.lowercase().replace("\\s+".toRegex(), "-") + "-" + System.currentTimeMillis().toString().takeLast(4)

        val event = EventEntity(
            organizer = organizer,
            title = request.title,
            slug = slug,
            description = request.description,
            eventType = request.eventType ?: "workshop",
            location = request.location,
            isVirtual = request.isVirtual,
            meetingLink = request.meetingLink,
            startTime = request.startTime ?: Instant.now(),
            endTime = request.endTime,
            bannerUrl = request.bannerUrl,
            maxAttendees = request.maxAttendees
        )

        val saved = eventRepository.save(event)
        return eventMapper.toResponse(saved, false)
    }

    fun registerForEvent(eventId: UUID): Boolean {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val event = eventRepository.findByIdAndDeletedAtIsNull(eventId)
            .orElseThrow { ResourceNotFoundException("Event with id $eventId not found") }

        val profile = profileRepository.findById(currentUserId)
            .orElseThrow { ResourceNotFoundException("User profile not found") }

        // Use distributed lock to prevent exceeding event attendee capacity in concurrent bursts
        redisDistributedLock.withLock("event:register:$eventId") {
            if (event.maxAttendees != null && event.registrationsCount >= event.maxAttendees!!) {
                throw BadRequestException("Event is fully booked")
            }

            if (!eventRegistrationRepository.existsByEventIdAndProfileId(eventId, currentUserId)) {
                val reg = eventRegistrationRepository.save(EventRegistrationEntity(event = event, profile = profile))
                event.registrationsCount += 1
                eventRepository.save(event)

                domainEventPublisher.publishEventRegistered(
                    EventRegisteredEvent(
                        eventRegistrationId = reg.id.toString(),
                        targetEventId = event.id.toString(),
                        eventTitle = event.title,
                        attendeeId = profile.id.toString(),
                        attendeeName = profile.fullName
                    )
                )
            }
        }

        return true
    }

    fun registerForEvent(eventId: String): Boolean = registerForEvent(eventId.toUUID())

    fun updateEvent(id: String, request: com.acadyk.modules.events.dto.UpdateEventRequest): EventResponse {
        val event = eventRepository.findByIdAndDeletedAtIsNull(id.toUUID())
            .orElseThrow { ResourceNotFoundException("Event with id $id not found") }

        request.title?.let {
            event.title = it
            event.slug = it.lowercase().replace("\\s+".toRegex(), "-") + "-" + System.currentTimeMillis().toString().takeLast(4)
        }
        request.description?.let { event.description = it }
        request.eventType?.let { event.eventType = it }
        request.location?.let { event.location = it }
        request.isVirtual?.let { event.isVirtual = it }
        request.meetingLink?.let { event.meetingLink = it }
        request.startTime?.let { event.startTime = it }
        request.endTime?.let { event.endTime = it }
        request.bannerUrl?.let { event.bannerUrl = it }
        request.maxAttendees?.let { event.maxAttendees = it }
        event.updatedAt = Instant.now()
        val saved = eventRepository.save(event)
        return eventMapper.toResponse(saved, false)
    }

    fun deleteEvent(id: String) {
        val event = eventRepository.findByIdAndDeletedAtIsNull(id.toUUID())
            .orElseThrow { ResourceNotFoundException("Event with id $id not found") }
        event.deletedAt = Instant.now()
        event.updatedAt = Instant.now()
        eventRepository.save(event)
    }
}
