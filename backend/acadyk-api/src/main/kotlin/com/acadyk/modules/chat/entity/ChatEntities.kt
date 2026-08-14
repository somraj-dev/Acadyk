package com.acadyk.modules.chat.entity

import com.acadyk.modules.profiles.entity.ProfileEntity
import jakarta.persistence.*
import java.time.Instant
import java.util.UUID

@Entity
@Table(name = "conversations")
data class ConversationEntity(
    @Id
    val id: String = UUID.randomUUID().toString(),

    var isGroup: Boolean = false,
    var title: String? = null,
    var avatarUrl: String? = null,
    var lastMessageText: String? = null,
    var lastMessageAt: Instant = Instant.now(),

    @Column(nullable = false)
    val createdAt: Instant = Instant.now(),

    @Column(nullable = false)
    var updatedAt: Instant = Instant.now(),

    var deletedAt: Instant? = null
)

@Entity
@Table(name = "conversation_members")
data class ConversationMemberEntity(
    @Id
    val id: String = UUID.randomUUID().toString(),

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "conversation_id", nullable = false)
    val conversation: ConversationEntity,

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "profile_id", nullable = false)
    val profile: ProfileEntity,

    var isAdmin: Boolean = false,
    val joinedAt: Instant = Instant.now(),
    var lastReadAt: Instant = Instant.now(),
    var mutedUntil: Instant? = null
)

@Entity
@Table(name = "messages")
data class MessageEntity(
    @Id
    val id: String = UUID.randomUUID().toString(),

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "conversation_id", nullable = false)
    val conversation: ConversationEntity,

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "sender_id", nullable = false)
    val sender: ProfileEntity,

    @Column(columnDefinition = "TEXT", nullable = false)
    var content: String,

    var messageType: String = "TEXT",
    var mediaUrl: String? = null,
    var isEdited: Boolean = false,

    @Column(nullable = false)
    val createdAt: Instant = Instant.now(),

    @Column(nullable = false)
    var updatedAt: Instant = Instant.now(),

    var deletedAt: Instant? = null
)

@Entity
@Table(name = "message_reads")
data class MessageReadEntity(
    @Id
    val id: String = UUID.randomUUID().toString(),

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "message_id", nullable = false)
    val message: MessageEntity,

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "profile_id", nullable = false)
    val profile: ProfileEntity,

    val readAt: Instant = Instant.now()
)
