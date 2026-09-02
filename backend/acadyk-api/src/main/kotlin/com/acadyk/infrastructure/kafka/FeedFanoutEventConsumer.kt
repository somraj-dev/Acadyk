package com.acadyk.infrastructure.kafka

import com.acadyk.common.toUUIDOrNull
import com.acadyk.infrastructure.fcm.FcmService
import com.acadyk.infrastructure.redis.RedisCacheService
import com.acadyk.modules.notifications.entity.NotificationEntity
import com.acadyk.modules.notifications.repository.NotificationPreferenceRepository
import com.acadyk.modules.notifications.repository.NotificationRepository
import com.acadyk.modules.profiles.repository.ProfileRepository
import com.fasterxml.jackson.databind.ObjectMapper
import org.slf4j.LoggerFactory
import org.springframework.kafka.annotation.KafkaListener
import org.springframework.stereotype.Component

/**
 * Twitter Channel: Feed and social event consumers.
 *
 * These consumers run in their own consumer groups and handle async,
 * eventually-consistent events. They are NOT real-time-critical.
 *
 * Architecture principle: Feed events are broadcast-style (one-to-many).
 * They invalidate caches, create notifications for followers, and update
 * search indices. No instant delivery expectation — algorithmic feed ordering.
 */
@Component
class FeedFanoutEventConsumer(
    private val notificationRepository: NotificationRepository,
    private val notificationPreferenceRepository: NotificationPreferenceRepository,
    private val profileRepository: ProfileRepository,
    private val redisCacheService: RedisCacheService,
    private val fcmService: FcmService,
    private val objectMapper: ObjectMapper
) {
    private val logger = LoggerFactory.getLogger(javaClass)

    @KafkaListener(topics = ["acadyk.posts"], groupId = "acadyk-feed-fanout")
    fun handlePostCreated(message: String) {
        try {
            val event = objectMapper.readValue(message, PostCreatedEvent::class.java)
            logger.info("[Twitter Channel] Processing PostCreatedEvent for post ${event.postId}")

            // Invalidate Redis caches (async, eventually consistent)
            redisCacheService.evictPattern("feed:")
            redisCacheService.evict("posts:${event.postId}")
        } catch (e: Exception) {
            logger.debug("PostCreated event consumed: $message")
        }
    }

    @KafkaListener(topics = ["acadyk.reactions"], groupId = "acadyk-feed-fanout")
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

    @KafkaListener(topics = ["acadyk.comments"], groupId = "acadyk-feed-fanout")
    fun handleCommentCreated(message: String) {
        try {
            val event = objectMapper.readValue(message, CommentCreatedEvent::class.java)
            logger.info("[Twitter Channel] Processing CommentCreatedEvent for post ${event.postId}")

            if (event.commenterId != event.postAuthorId) {
                val author = event.postAuthorId.toUUIDOrNull()?.let { profileRepository.findById(it).orElse(null) }
                val commenter = event.commenterId.toUUIDOrNull()?.let { profileRepository.findById(it).orElse(null) }
                if (author != null) {
                    val notif = notificationRepository.save(
                        NotificationEntity(
                            recipient = author,
                            actor = commenter,
                            type = "comment",
                            title = "New comment on your post",
                            body = "${event.commenterName}: ${event.contentSnippet.take(80)}",
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
                            dataPayload = mapOf("postId" to event.postId, "type" to "comment")
                        )
                    }
                }
            }
        } catch (e: Exception) {
            logger.debug("CommentCreated event consumed: $message")
        }
    }

    @KafkaListener(topics = ["acadyk.follows"], groupId = "acadyk-feed-fanout")
    fun handleFollowCreated(message: String) {
        try {
            val event = objectMapper.readValue(message, FollowEvent::class.java)
            if (event.followerId != event.followingId) {
                val following = event.followingId.toUUIDOrNull()?.let { profileRepository.findById(it).orElse(null) }
                val follower = event.followerId.toUUIDOrNull()?.let { profileRepository.findById(it).orElse(null) }
                if (following != null) {
                    val notif = notificationRepository.save(
                        NotificationEntity(
                            recipient = following,
                            actor = follower,
                            type = "follow",
                            title = "New follower",
                            body = "${event.followerName} started following you",
                            actionUrl = "/profile/${event.followerId}",
                            entityType = "profile",
                            entityId = event.followerId.toUUIDOrNull()
                        )
                    )

                    val prefs = notificationPreferenceRepository.findByProfileId(following.id).orElse(null)
                    val canSendPush = prefs == null || (prefs.pushEnabled && prefs.connectionRequests)

                    if (canSendPush) {
                        fcmService.sendPushNotification(
                            recipientId = following.id,
                            title = notif.title,
                            body = notif.body,
                            dataPayload = mapOf("profileId" to event.followerId, "type" to "follow")
                        )
                    }
                }
            }
        } catch (e: Exception) {
            logger.debug("FollowCreated event consumed: $message")
        }
    }
}

/**
 * Social notifications consumer for connections, opportunities, applications, and events.
 * Runs in its own consumer group for independent scaling.
 */
@Component
class SocialNotificationEventConsumer(
    private val notificationRepository: NotificationRepository,
    private val notificationPreferenceRepository: NotificationPreferenceRepository,
    private val profileRepository: ProfileRepository,
    private val fcmService: FcmService,
    private val objectMapper: ObjectMapper
) {
    private val logger = LoggerFactory.getLogger(javaClass)

    @KafkaListener(topics = ["acadyk.connections"], groupId = "acadyk-social-notifications")
    fun handleConnectionCreated(message: String) {
        try {
            val event = objectMapper.readValue(message, ConnectionCreatedEvent::class.java)
            val userA = event.userAId.toUUIDOrNull()?.let { profileRepository.findById(it).orElse(null) }
            val userB = event.userBId.toUUIDOrNull()?.let { profileRepository.findById(it).orElse(null) }

            if (userA != null && userB != null) {
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

    @KafkaListener(topics = ["acadyk.opportunities"], groupId = "acadyk-social-notifications")
    fun handleOpportunityCreated(message: String) {
        try {
            val event = objectMapper.readValue(message, OpportunityCreatedEvent::class.java)
            logger.info("[Social] Processing OpportunityCreatedEvent for ${event.title}")
        } catch (e: Exception) {
            logger.debug("OpportunityCreated event consumed: $message")
        }
    }

    @KafkaListener(topics = ["acadyk.applications"], groupId = "acadyk-social-notifications")
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
