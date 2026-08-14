package com.acadyk.modules.connections.entity

import com.acadyk.modules.profiles.entity.ProfileEntity
import jakarta.persistence.*
import java.time.Instant
import java.util.UUID

@Entity
@Table(name = "connections")
data class ConnectionEntity(
    @Id
    val id: String = UUID.randomUUID().toString(),

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "user_a_id", nullable = false)
    val userA: ProfileEntity,

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "user_b_id", nullable = false)
    val userB: ProfileEntity,

    @Column(nullable = false)
    val connectedAt: Instant = Instant.now()
)

@Entity
@Table(name = "connection_requests")
data class ConnectionRequestEntity(
    @Id
    val id: String = UUID.randomUUID().toString(),

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "sender_id", nullable = false)
    val sender: ProfileEntity,

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "recipient_id", nullable = false)
    val recipient: ProfileEntity,

    var status: String = "PENDING",
    var message: String? = null,

    @Column(nullable = false)
    val createdAt: Instant = Instant.now(),

    var respondedAt: Instant? = null
)

@Entity
@Table(name = "follows")
data class FollowEntity(
    @Id
    val id: String = UUID.randomUUID().toString(),

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "follower_id", nullable = false)
    val follower: ProfileEntity,

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "following_id", nullable = false)
    val following: ProfileEntity,

    @Column(nullable = false)
    val createdAt: Instant = Instant.now()
)
