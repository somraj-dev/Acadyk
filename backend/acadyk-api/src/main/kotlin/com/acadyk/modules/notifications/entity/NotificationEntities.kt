package com.acadyk.modules.notifications.entity

import com.acadyk.modules.profiles.entity.ProfileEntity
import jakarta.persistence.*
import java.time.Instant
import java.util.UUID

@Entity
@Table(name = "notifications")
data class NotificationEntity(
    @Id
    val id: UUID = UUID.randomUUID(),

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "recipient_id", nullable = false)
    val recipient: ProfileEntity,

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "actor_id")
    val actor: ProfileEntity? = null,

    var type: String = "general",

    @Column(nullable = false)
    var title: String,

    @Column(columnDefinition = "TEXT", nullable = false)
    var body: String,

    var actionUrl: String? = null,
    var entityType: String? = null,
    var entityId: UUID? = null,
    var isRead: Boolean = false,
    var readAt: Instant? = null,

    @Column(nullable = false)
    val createdAt: Instant = Instant.now()
)

@Entity
@Table(name = "notification_preferences")
data class NotificationPreferenceEntity(
    @Id
    val id: UUID = UUID.randomUUID(),

    @Column(nullable = false, unique = true)
    val profileId: UUID,

    var pushEnabled: Boolean = true,
    var emailEnabled: Boolean = true,
    var likesEnabled: Boolean = true,
    var commentsEnabled: Boolean = true,
    var connectionsEnabled: Boolean = true,
    var opportunitiesEnabled: Boolean = true,
    var eventsEnabled: Boolean = true,
    var messagesEnabled: Boolean = true,
    var communitiesEnabled: Boolean = true,
    var marketingEmails: Boolean = false,

    @Column(nullable = false)
    val createdAt: Instant = Instant.now(),

    @Column(nullable = false)
    var updatedAt: Instant = Instant.now()
)
