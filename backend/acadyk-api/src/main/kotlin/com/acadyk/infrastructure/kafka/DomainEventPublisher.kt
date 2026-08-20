package com.acadyk.infrastructure.kafka

import com.fasterxml.jackson.databind.ObjectMapper
import org.slf4j.LoggerFactory
import org.springframework.kafka.core.KafkaTemplate
import org.springframework.stereotype.Service

@Service
class DomainEventPublisher(
    private val kafkaTemplate: KafkaTemplate<String, String>,
    private val objectMapper: ObjectMapper
) {
    private val logger = LoggerFactory.getLogger(javaClass)

    fun publish(event: DomainEvent, topic: String, partitionKey: String) {
        try {
            val json = objectMapper.writeValueAsString(event)
            kafkaTemplate.send(topic, partitionKey, json)
            logger.debug("Domain event [${event.eventType}] published to topic $topic with key $partitionKey")
        } catch (e: Exception) {
            logger.warn("Domain event [${event.eventType}] dispatch bypassed (offline/dev fallback): ${e.message}")
        }
    }

    fun publishUserCreated(event: UserCreatedEvent) = publish(event, "acadyk.users", event.userId)
    fun publishProfileUpdated(event: ProfileUpdatedEvent) = publish(event, "acadyk.profiles", event.profileId)
    fun publishPostCreated(event: PostCreatedEvent) = publish(event, "acadyk.posts", event.postId)
    fun publishPostLiked(event: PostLikedEvent) = publish(event, "acadyk.reactions", event.postId)
    fun publishCommentCreated(event: CommentCreatedEvent) = publish(event, "acadyk.comments", event.postId)
    fun publishConnectionCreated(event: ConnectionCreatedEvent) = publish(event, "acadyk.connections", event.userAId)
    fun publishOpportunityCreated(event: OpportunityCreatedEvent) = publish(event, "acadyk.opportunities", event.opportunityId)
    fun publishApplicationSubmitted(event: ApplicationSubmittedEvent) = publish(event, "acadyk.applications", event.opportunityId)
    fun publishEventRegistered(event: EventRegisteredEvent) = publish(event, "acadyk.events", event.targetEventId)
    fun publishMessageSent(event: MessageSentEvent) = publish(event, "acadyk.chat", event.conversationId)
    fun publishNotificationCreated(event: NotificationCreatedEvent) = publish(event, "acadyk.notifications", event.recipientId)
    fun publishFollowEvent(event: FollowEvent) = publish(event, "acadyk.follows", event.followingId)
}
