package com.acadyk.infrastructure.kafka

import java.time.Instant
import java.util.UUID

sealed interface DomainEvent {
    val eventId: String
    val eventType: String
    val timestamp: Instant
}

data class UserCreatedEvent(
    override val eventId: String = UUID.randomUUID().toString(),
    override val eventType: String = "UserCreated",
    override val timestamp: Instant = Instant.now(),
    val userId: String,
    val email: String,
    val role: String
) : DomainEvent

data class ProfileUpdatedEvent(
    override val eventId: String = UUID.randomUUID().toString(),
    override val eventType: String = "ProfileUpdated",
    override val timestamp: Instant = Instant.now(),
    val profileId: String,
    val fullName: String,
    val collegeName: String?
) : DomainEvent

data class PostCreatedEvent(
    override val eventId: String = UUID.randomUUID().toString(),
    override val eventType: String = "PostCreated",
    override val timestamp: Instant = Instant.now(),
    val postId: String,
    val authorId: String,
    val contentSnippet: String,
    val postType: String
) : DomainEvent

data class PostLikedEvent(
    override val eventId: String = UUID.randomUUID().toString(),
    override val eventType: String = "PostLiked",
    override val timestamp: Instant = Instant.now(),
    val postId: String,
    val authorId: String,
    val likerId: String,
    val likerName: String
) : DomainEvent

data class CommentCreatedEvent(
    override val eventId: String = UUID.randomUUID().toString(),
    override val eventType: String = "CommentCreated",
    override val timestamp: Instant = Instant.now(),
    val commentId: String,
    val postId: String,
    val postAuthorId: String,
    val commenterId: String,
    val commenterName: String,
    val contentSnippet: String
) : DomainEvent

data class ConnectionCreatedEvent(
    override val eventId: String = UUID.randomUUID().toString(),
    override val eventType: String = "ConnectionCreated",
    override val timestamp: Instant = Instant.now(),
    val userAId: String,
    val userBId: String,
    val userAName: String
) : DomainEvent

data class OpportunityCreatedEvent(
    override val eventId: String = UUID.randomUUID().toString(),
    override val eventType: String = "OpportunityCreated",
    override val timestamp: Instant = Instant.now(),
    val opportunityId: String,
    val title: String,
    val companyName: String,
    val opportunityType: String
) : DomainEvent

data class ApplicationSubmittedEvent(
    override val eventId: String = UUID.randomUUID().toString(),
    override val eventType: String = "ApplicationSubmitted",
    override val timestamp: Instant = Instant.now(),
    val applicationId: String,
    val opportunityId: String,
    val opportunityTitle: String,
    val posterId: String?,
    val applicantId: String,
    val applicantName: String
) : DomainEvent

data class EventRegisteredEvent(
    override val eventId: String = UUID.randomUUID().toString(),
    override val eventType: String = "EventRegistered",
    override val timestamp: Instant = Instant.now(),
    val eventRegistrationId: String,
    val targetEventId: String,
    val eventTitle: String,
    val attendeeId: String,
    val attendeeName: String
) : DomainEvent

data class MessageSentEvent(
    override val eventId: String = UUID.randomUUID().toString(),
    override val eventType: String = "MessageSent",
    override val timestamp: Instant = Instant.now(),
    val messageId: String,
    val conversationId: String,
    val senderId: String,
    val senderName: String,
    val contentSnippet: String,
    val recipientIds: List<String>
) : DomainEvent

data class NotificationCreatedEvent(
    override val eventId: String = UUID.randomUUID().toString(),
    override val eventType: String = "NotificationCreated",
    override val timestamp: Instant = Instant.now(),
    val notificationId: String,
    val recipientId: String,
    val title: String,
    val body: String,
    val type: String
) : DomainEvent

data class FollowEvent(
    override val eventId: String = UUID.randomUUID().toString(),
    override val eventType: String = "FollowCreated",
    override val timestamp: Instant = Instant.now(),
    val followerId: String,
    val followerName: String,
    val followingId: String
) : DomainEvent

