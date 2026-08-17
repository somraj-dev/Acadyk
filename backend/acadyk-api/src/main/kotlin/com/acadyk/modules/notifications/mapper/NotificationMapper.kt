package com.acadyk.modules.notifications.mapper

import com.acadyk.modules.notifications.dto.NotificationPreferencesDto
import com.acadyk.modules.notifications.dto.NotificationResponse
import com.acadyk.modules.notifications.entity.NotificationEntity
import com.acadyk.modules.notifications.entity.NotificationPreferenceEntity
import org.springframework.stereotype.Component

@Component
class NotificationMapper {

    fun toResponse(entity: NotificationEntity): NotificationResponse {
        return NotificationResponse(
            id = entity.id.toString(),
            type = entity.type,
            title = entity.title,
            body = entity.body,
            actionUrl = entity.actionUrl,
            entityType = entity.entityType,
            entityId = entity.entityId?.toString(),
            isRead = entity.isRead,
            actorName = entity.actor?.fullName,
            actorPhotoUrl = entity.actor?.profilePhotoUrl,
            createdAt = entity.createdAt
        )
    }

    fun toDto(entity: NotificationPreferenceEntity): NotificationPreferencesDto {
        return NotificationPreferencesDto(
            pushEnabled = entity.pushEnabled,
            emailEnabled = entity.emailEnabled,
            likesEnabled = entity.chatNotifications,
            commentsEnabled = entity.chatNotifications,
            connectionsEnabled = entity.connectionRequests,
            opportunitiesEnabled = entity.eventReminders,
            eventsEnabled = entity.eventReminders,
            messagesEnabled = entity.chatNotifications,
            communitiesEnabled = entity.connectionRequests,
            marketingEmails = entity.marketingEmails
        )
    }
}
