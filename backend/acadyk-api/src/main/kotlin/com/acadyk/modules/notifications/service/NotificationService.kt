package com.acadyk.modules.notifications.service

import com.acadyk.common.PageResponse
import com.acadyk.common.toUUID
import com.acadyk.infrastructure.fcm.FcmService
import com.acadyk.modules.notifications.dto.NotificationPreferencesDto
import com.acadyk.modules.notifications.dto.NotificationResponse
import com.acadyk.modules.notifications.entity.NotificationPreferenceEntity
import com.acadyk.modules.notifications.mapper.NotificationMapper
import com.acadyk.modules.notifications.repository.NotificationPreferenceRepository
import com.acadyk.modules.notifications.repository.NotificationRepository
import com.acadyk.security.CurrentUserProvider
import org.springframework.data.domain.PageRequest
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.util.UUID

@Service
@Transactional
class NotificationService(
    private val notificationRepository: NotificationRepository,
    private val notificationPreferenceRepository: NotificationPreferenceRepository,
    private val notificationMapper: NotificationMapper,
    private val currentUserProvider: CurrentUserProvider,
    private val fcmService: FcmService
) {

    @Transactional(readOnly = true)
    fun getNotifications(page: Int, size: Int): PageResponse<NotificationResponse> {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val pageable = PageRequest.of(page, size)
        val notificationsPage = notificationRepository.findAllByRecipientIdOrderByCreatedAtDesc(currentUserId, pageable)
        return PageResponse.from(notificationsPage, notificationMapper::toResponse)
    }

    @Transactional(readOnly = true)
    fun getUnreadCount(): Long {
        val currentUserId = currentUserProvider.getCurrentUserId()
        return notificationRepository.countByRecipientIdAndIsReadFalse(currentUserId)
    }

    fun markAsRead(id: UUID) {
        val currentUserId = currentUserProvider.getCurrentUserId()
        notificationRepository.findByIdAndRecipientId(id, currentUserId).ifPresent {
            it.isRead = true
            it.readAt = Instant.now()
            notificationRepository.save(it)
        }
    }

    fun markAsRead(id: String) = markAsRead(id.toUUID())

    fun markAllAsRead() {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val unread = notificationRepository.findAllByRecipientIdOrderByCreatedAtDesc(currentUserId, PageRequest.of(0, 100))
        unread.forEach {
            it.isRead = true
            it.readAt = Instant.now()
        }
        notificationRepository.saveAll(unread)
    }

    @Transactional(readOnly = true)
    fun getPreferences(): NotificationPreferencesDto {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val entity = notificationPreferenceRepository.findByProfileId(currentUserId).orElseGet {
            NotificationPreferenceEntity(profileId = currentUserId)
        }
        return notificationMapper.toDto(entity)
    }

    fun updatePreferences(dto: NotificationPreferencesDto): NotificationPreferencesDto {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val entity = notificationPreferenceRepository.findByProfileId(currentUserId).orElseGet {
            NotificationPreferenceEntity(profileId = currentUserId)
        }

        entity.pushEnabled = dto.pushEnabled
        entity.emailEnabled = dto.emailEnabled
        entity.likesEnabled = dto.likesEnabled
        entity.commentsEnabled = dto.commentsEnabled
        entity.connectionsEnabled = dto.connectionsEnabled
        entity.opportunitiesEnabled = dto.opportunitiesEnabled
        entity.eventsEnabled = dto.eventsEnabled
        entity.messagesEnabled = dto.messagesEnabled
        entity.communitiesEnabled = dto.communitiesEnabled
        entity.marketingEmails = dto.marketingEmails
        entity.updatedAt = Instant.now()

        val saved = notificationPreferenceRepository.save(entity)
        return notificationMapper.toDto(saved)
    }

    fun registerFcmToken(fcmToken: String) {
        val currentUserId = currentUserProvider.getCurrentUserId()
        fcmService.registerToken(currentUserId, fcmToken)
    }
}
