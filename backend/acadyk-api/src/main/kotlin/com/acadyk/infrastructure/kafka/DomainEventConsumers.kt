package com.acadyk.infrastructure.kafka

import com.acadyk.common.toUUIDOrNull
import com.acadyk.infrastructure.fcm.FcmService
import com.acadyk.infrastructure.redis.RedisCacheService
import com.acadyk.modules.notifications.entity.NotificationEntity
import com.acadyk.modules.notifications.repository.NotificationPreferenceRepository
import com.acadyk.modules.notifications.repository.NotificationRepository
import com.acadyk.modules.profiles.repository.ProfileRepository
import com.acadyk.modules.search.document.OpportunitySearchDocument
import com.acadyk.modules.search.document.PostSearchDocument
import com.acadyk.modules.search.service.SearchService
import com.fasterxml.jackson.databind.ObjectMapper
import org.slf4j.LoggerFactory
import org.springframework.kafka.annotation.KafkaListener
import org.springframework.stereotype.Component
import java.time.Instant

@Component
class DomainEventConsumers(
    private val notificationRepository: NotificationRepository,
    private val notificationPreferenceRepository: NotificationPreferenceRepository,
    private val profileRepository: ProfileRepository,
    private val redisCacheService: RedisCacheService,
    private val searchService: SearchService,
    private val fcmService: FcmService,
    private val objectMapper: ObjectMapper
) {
    private val logger = LoggerFactory.getLogger(javaClass)

    @KafkaListener(topics = ["acadyk.posts"], groupId = "acadyk-post-processors")
    fun handlePostCreated(message: String) {
        try {
            val event = objectMapper.readValue(message, PostCreatedEvent::class.java)
            logger.info("Kafka async consumer: Processing PostCreatedEvent for post ${event.postId}")

            // 1. Invalidate Redis caches
            redisCacheService.evictPattern("feed:")
            redisCacheService.evict("posts:${event.postId}")

            // 2. Index in Elasticsearch asynchronously
            val author = event.authorId.toUUIDOrNull()?.let { profileRepository.findById(it).orElse(null) }
            searchService.indexPost(
                PostSearchDocument(
                    id = event.postId,
                    content = event.contentSnippet,
                    authorId = event.authorId,
                    authorName = author?.fullName ?: "Acadyk Member",
                    postType = event.postType,
                    createdAt = Instant.now()
                )
            )
        } catch (e: Exception) {
            logger.debug("PostCreated event consumed: $message")
        }
    }

    @KafkaListener(topics = ["acadyk.chat"], groupId = "acadyk-chat-notifications")
    fun handleMessageSent(message: String) {
        try {
            val event = objectMapper.readValue(message, MessageSentEvent::class.java)
            logger.info("Kafka async consumer: Processing MessageSentEvent in conversation ${event.conversationId}")

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

    @KafkaListener(topics = ["acadyk.connections"], groupId = "acadyk-connection-notifications")
    fun handleConnectionCreated(message: String) {
        try {
            val event = objectMapper.readValue(message, ConnectionCreatedEvent::class.java)
            val userA = event.userAId.toUUIDOrNull()?.let { profileRepository.findById(it).orElse(null) }
            val userB = event.userBId.toUUIDOrNull()?.let { profileRepository.findById(it).orElse(null) }

            if (userA != null && userB != null) {
                // 1. PostgreSQL in-app notification
                val notif = notificationRepository.save(
                    NotificationEntity(
                        recipient = userB,
                        actor = userA,
                        type = "connection_accepted",
                        title = "Connected with ${event.userAName}",
                        body = "${event.userAName} and you are now connected!",
                        actionUrl = "/profile/${userA.id}",
                        entityType = "profile",
                        entityId = userA.id
                    )
                )

                // 2. Check preferences & dispatch FCM push
                val prefs = notificationPreferenceRepository.findByProfileId(userB.id).orElse(null)
                val canSendPush = prefs == null || (prefs.pushEnabled && prefs.connectionRequests)

                if (canSendPush) {
                    fcmService.sendPushNotification(
                        recipientId = userB.id,
                        title = notif.title,
                        body = notif.body,
                        dataPayload = mapOf("profileId" to userA.id.toString(), "type" to "connection_accepted")
                    )
                }
            }
        } catch (e: Exception) {
            logger.debug("ConnectionCreated event consumed: $message")
        }
    }

    @KafkaListener(topics = ["acadyk.reactions"], groupId = "acadyk-reaction-notifications")
    fun handlePostLiked(message: String) {
        try {
            val event = objectMapper.readValue(message, PostLikedEvent::class.java)
            if (event.authorId != event.likerId) {
                val author = event.authorId.toUUIDOrNull()?.let { profileRepository.findById(it).orElse(null) }
                val liker = event.likerId.toUUIDOrNull()?.let { profileRepository.findById(it).orElse(null) }
                if (author != null) {
                    val notif = notificationRepository.save(
                        NotificationEntity(
                            recipient = author,
                            actor = liker,
                            type = "post_like",
                            title = "New reaction on your post",
                            body = "${event.likerName} liked your post",
                            actionUrl = "/posts/${event.postId}",
                            entityType = "post",
                            entityId = event.postId.toUUIDOrNull()
                        )
                    )

                    val prefs = notificationPreferenceRepository.findByProfileId(author.id).orElse(null)
                    val canSendPush = prefs == null || prefs.pushEnabled

                    if (canSendPush) {
                        fcmService.sendPushNotification(
                            recipientId = author.id,
                            title = notif.title,
                            body = notif.body,
                            dataPayload = mapOf("postId" to event.postId, "type" to "post_like")
                        )
                    }
                }
            }
        } catch (e: Exception) {
            logger.debug("PostLiked event consumed: $message")
        }
    }

    @KafkaListener(topics = ["acadyk.opportunities"], groupId = "acadyk-opportunity-processors")
    fun handleOpportunityCreated(message: String) {
        try {
            val event = objectMapper.readValue(message, OpportunityCreatedEvent::class.java)
            searchService.indexOpportunity(
                OpportunitySearchDocument(
                    id = event.opportunityId,
                    title = event.title,
                    companyName = event.companyName,
                    opportunityType = event.opportunityType,
                    description = event.title,
                    location = "Remote / Onsite",
                    isRemote = true
                )
            )
        } catch (e: Exception) {
            logger.debug("OpportunityCreated event consumed: $message")
        }
    }

    @KafkaListener(topics = ["acadyk.applications"], groupId = "acadyk-application-notifications")
    fun handleApplicationSubmitted(message: String) {
        try {
            val event = objectMapper.readValue(message, ApplicationSubmittedEvent::class.java)
            if (event.posterId != null) {
                val poster = event.posterId.toUUIDOrNull()?.let { profileRepository.findById(it).orElse(null) }
                val applicant = event.applicantId.toUUIDOrNull()?.let { profileRepository.findById(it).orElse(null) }
                if (poster != null) {
                    val notif = notificationRepository.save(
                        NotificationEntity(
                            recipient = poster,
                            actor = applicant,
                            type = "opportunity_application",
                            title = "New applicant for ${event.opportunityTitle}",
                            body = "${event.applicantName} applied for your opportunity posting",
                            actionUrl = "/opportunities/${event.opportunityId}/applications",
                            entityType = "opportunity",
                            entityId = event.opportunityId.toUUIDOrNull()
                        )
                    )

                    val prefs = notificationPreferenceRepository.findByProfileId(poster.id).orElse(null)
                    val canSendPush = prefs == null || (prefs.pushEnabled && prefs.eventReminders)

                    if (canSendPush) {
                        fcmService.sendPushNotification(
                            recipientId = poster.id,
                            title = notif.title,
                            body = notif.body,
                            dataPayload = mapOf("opportunityId" to event.opportunityId, "type" to "opportunity_application")
                        )
                    }
                }
            }
        } catch (e: Exception) {
            logger.debug("ApplicationSubmitted event consumed: $message")
        }
    }
}
