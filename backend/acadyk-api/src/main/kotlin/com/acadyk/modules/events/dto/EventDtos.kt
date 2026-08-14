package com.acadyk.modules.events.dto

import jakarta.validation.constraints.NotBlank
import java.time.Instant

data class CreateEventRequest(
    @field:NotBlank(message = "Event title is required")
    val title: String,

    val description: String? = null,
    val eventType: String? = "workshop",
    val location: String? = null,
    val isVirtual: Boolean = false,
    val meetingLink: String? = null,
    val startTime: Instant? = null,
    val endTime: Instant? = null,
    val bannerUrl: String? = null,
    val maxAttendees: Int? = null
)

data class EventResponse(
    val id: String,
    val title: String,
    val slug: String,
    val description: String?,
    val eventType: String,
    val location: String?,
    val isVirtual: Boolean,
    val meetingLink: String?,
    val startTime: Instant,
    val endTime: Instant?,
    val bannerUrl: String?,
    val maxAttendees: Int?,
    val registrationsCount: Int,
    val organizerName: String?,
    val isRegistered: Boolean = false,
    val createdAt: Instant
)
