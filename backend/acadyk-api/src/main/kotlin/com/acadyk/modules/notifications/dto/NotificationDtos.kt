package com.acadyk.modules.notifications.dto

import jakarta.validation.constraints.NotBlank
import java.time.Instant

data class NotificationResponse(
    val id: String,
    val type: String,
    val title: String,
    val body: String,
    val actionUrl: String?,
    val entityType: String?,
    val entityId: String?,
    val isRead: Boolean,
    val actorName: String?,
    val actorPhotoUrl: String?,
    val createdAt: Instant
)

data class NotificationPreferencesDto(
    val pushEnabled: Boolean = true,
    val emailEnabled: Boolean = true,
    val likesEnabled: Boolean = true,
    val commentsEnabled: Boolean = true,
    val connectionsEnabled: Boolean = true,
    val opportunitiesEnabled: Boolean = true,
    val eventsEnabled: Boolean = true,
    val messagesEnabled: Boolean = true,
    val communitiesEnabled: Boolean = true,
    val marketingEmails: Boolean = false
)

data class RegisterFcmTokenRequest(
    @field:NotBlank(message = "FCM token cannot be blank")
    val fcmToken: String
)
