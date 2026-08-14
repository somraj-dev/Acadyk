package com.acadyk.modules.events.mapper

import com.acadyk.modules.events.dto.EventResponse
import com.acadyk.modules.events.entity.EventEntity
import org.springframework.stereotype.Component

@Component
class EventMapper {

    fun toResponse(entity: EventEntity, isRegistered: Boolean = false): EventResponse {
        return EventResponse(
            id = entity.id,
            title = entity.title,
            slug = entity.slug,
            description = entity.description,
            eventType = entity.eventType,
            location = entity.location,
            isVirtual = entity.isVirtual,
            meetingLink = entity.meetingLink,
            startTime = entity.startTime,
            endTime = entity.endTime,
            bannerUrl = entity.bannerUrl,
            maxAttendees = entity.maxAttendees,
            registrationsCount = entity.registrationsCount,
            organizerName = entity.organizer?.fullName ?: "Acadyk Community",
            isRegistered = isRegistered,
            createdAt = entity.createdAt
        )
    }
}
