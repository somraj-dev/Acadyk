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
            likesEnabled = entity.likesEnabled,
            commentsEnabled = entity.commentsEnabled,
            connectionsEnabled = entity.connectionsEnabled,
            opportunitiesEnabled = entity.opportunitiesEnabled,
            eventsEnabled = entity.eventsEnabled,
            messagesEnabled = entity.messagesEnabled,
            communitiesEnabled = entity.communitiesEnabled,
            marketingEmails = entity.marketingEmails
        )
    }
}
