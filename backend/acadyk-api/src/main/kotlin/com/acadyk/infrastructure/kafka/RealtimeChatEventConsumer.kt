package com.acadyk.infrastructure.kafka

import com.acadyk.common.toUUIDOrNull
import com.acadyk.infrastructure.fcm.FcmService
import com.acadyk.modules.notifications.entity.NotificationEntity
import com.acadyk.modules.notifications.repository.NotificationPreferenceRepository
import com.acadyk.modules.notifications.repository.NotificationRepository
import com.acadyk.modules.profiles.repository.ProfileRepository
import com.fasterxml.jackson.databind.ObjectMapper
import org.slf4j.LoggerFactory
import org.springframework.kafka.annotation.KafkaListener
import org.springframework.stereotype.Component

/**
 * WhatsApp Channel: Real-time chat event consumer.
 *
 * This consumer runs in its own consumer group (acadyk-realtime-chat) and is
 * dedicated to high-priority, low-latency message notifications.
 *
 * Architecture principle: Chat events are real-time-critical. They must be
 * processed immediately for offline push notifications. This consumer is
 * isolated from feed/social consumers so it can be scaled independently.
 */
@Component
class RealtimeChatEventConsumer(
    private val notificationRepository: NotificationRepository,
    private val notificationPreferenceRepository: NotificationPreferenceRepository,
    private val profileRepository: ProfileRepository,
    private val fcmService: FcmService,
    private val objectMapper: ObjectMapper
) {
    private val logger = LoggerFactory.getLogger(javaClass)

    @KafkaListener(topics = ["acadyk.chat"], groupId = "acadyk-realtime-chat")
    fun handleMessageSent(message: String) {
        try {
            val event = objectMapper.readValue(message, MessageSentEvent::class.java)
            logger.info("[WhatsApp Channel] Processing MessageSentEvent in conversation ${event.conversationId}")

            val sender = event.senderId.toUUIDOrNull()?.let { profileRepository.findById(it).orElse(null) }

            event.recipientIds.forEach { recipientIdStr ->
                if (recipientIdStr != event.senderId) {
                    val recipient = recipientIdStr.toUUIDOrNull()?.let { profileRepository.findById(it).orElse(null) }
                    if (recipient != null) {
                        // 1. Persist in-app notification in PostgreSQL FIRST
                        val notif = notificationRepository.save(
                            NotificationEntity(
                                recipient = recipient,
                                actor = sender,
                                type = "chat_message",
                                title = "New message from ${event.senderName}",
                                body = event.contentSnippet.take(100),
                                actionUrl = "/chat/${event.conversationId}",
                                entityType = "conversation",
                                entityId = event.conversationId.toUUIDOrNull()
                            )
                        )

                        // 2. Check user notification preferences before sending FCM push
                        val prefs = notificationPreferenceRepository.findByProfileId(recipient.id).orElse(null)
                        val canSendPush = prefs == null || (prefs.pushEnabled && prefs.chatNotifications)

                        if (canSendPush) {
                            fcmService.sendPushNotification(
                                recipientId = recipient.id,
                                title = notif.title,
                                body = notif.body,
                                dataPayload = mapOf(
                                    "notificationId" to notif.id.toString(),
                                    "conversationId" to event.conversationId,
                                    "type" to "chat_message"
                                )
                            )
                        }
                    }
                }
            }
        } catch (e: Exception) {
            logger.debug("MessageSent event consumed: $message")
        }
    }
}
