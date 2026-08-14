package com.acadyk.infrastructure.kafka

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
            val author = profileRepository.findById(event.authorId).orElse(null)
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

            val sender = profileRepository.findById(event.senderId).orElse(null)

            event.recipientIds.forEach { recipientId ->
                if (recipientId != event.senderId) {
                    val recipient = profileRepository.findById(recipientId).orElse(null)
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
                                entityId = event.conversationId
                            )
                        )

                        // 2. Check user notification preferences before sending FCM push
                        val prefs = notificationPreferenceRepository.findByProfileId(recipientId).orElse(null)
                        val canSendPush = prefs == null || (prefs.pushEnabled && prefs.messagesEnabled)

                        if (canSendPush) {
                            fcmService.sendPushNotification(
                                recipientId = recipientId,
                                title = notif.title,
                                body = notif.body,
                                dataPayload = mapOf(
                                    "notificationId" to notif.id,
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
            val userA = profileRepository.findById(event.userAId).orElse(null)
            val userB = profileRepository.findById(event.userBId).orElse(null)

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
                val canSendPush = prefs == null || (prefs.pushEnabled && prefs.connectionsEnabled)

                if (canSendPush) {
                    fcmService.sendPushNotification(
                        recipientId = userB.id,
                        title = notif.title,
                        body = notif.body,
                        dataPayload = mapOf("profileId" to userA.id, "type" to "connection_accepted")
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
                val author = profileRepository.findById(event.authorId).orElse(null)
                val liker = profileRepository.findById(event.likerId).orElse(null)
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
                            entityId = event.postId
                        )
                    )

                    val prefs = notificationPreferenceRepository.findByProfileId(author.id).orElse(null)
                    val canSendPush = prefs == null || (prefs.pushEnabled && prefs.likesEnabled)

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
                val poster = profileRepository.findById(event.posterId).orElse(null)
                val applicant = profileRepository.findById(event.applicantId).orElse(null)
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
                            entityId = event.opportunityId
                        )
                    )

                    val prefs = notificationPreferenceRepository.findByProfileId(poster.id).orElse(null)
                    val canSendPush = prefs == null || (prefs.pushEnabled && prefs.opportunitiesEnabled)

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
