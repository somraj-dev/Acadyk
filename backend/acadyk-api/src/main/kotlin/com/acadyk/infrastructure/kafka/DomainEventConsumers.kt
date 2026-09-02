package com.acadyk.infrastructure.kafka

/**
 * DEPRECATED: This monolithic consumer has been split into architecture-aligned consumers:
 *
 * WhatsApp Channel (Real-Time):
 *   - [RealtimeChatEventConsumer] — Consumer group: acadyk-realtime-chat
 *     Handles: acadyk.chat (MessageSentEvent)
 *     Priority: High (instant FCM push for offline users)
 *
 * Twitter Channel (Async Fan-Out):
 *   - [FeedFanoutEventConsumer] — Consumer group: acadyk-feed-fanout
 *     Handles: acadyk.posts, acadyk.reactions, acadyk.comments, acadyk.follows
 *     Priority: Normal (cache invalidation, async notifications)
 *
 *   - [SocialNotificationEventConsumer] — Consumer group: acadyk-social-notifications
 *     Handles: acadyk.connections, acadyk.opportunities, acadyk.applications
 *     Priority: Normal (standard notification pipeline)
 *
 * This separation allows independent scaling of real-time chat vs feed consumers.
 *
 * @see RealtimeChatEventConsumer
 * @see FeedFanoutEventConsumer
 * @see SocialNotificationEventConsumer
 */
@Deprecated(
    message = "Split into RealtimeChatEventConsumer, FeedFanoutEventConsumer, and SocialNotificationEventConsumer",
    level = DeprecationLevel.WARNING
)
class DomainEventConsumersLegacy
