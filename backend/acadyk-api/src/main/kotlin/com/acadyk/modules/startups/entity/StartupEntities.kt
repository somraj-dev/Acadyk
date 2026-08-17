package com.acadyk.modules.startups.entity

import com.acadyk.modules.profiles.entity.ProfileEntity
import jakarta.persistence.*
import java.time.Instant
import java.util.UUID

@Entity
@Table(name = "startups")
data class StartupEntity(
    @Id
    val id: UUID = UUID.randomUUID(),

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "founder_id", nullable = false)
    val founder: ProfileEntity,

    @Column(nullable = false)
    var name: String,

    @Column(nullable = false, unique = true)
    var slug: String,

    @Column(nullable = false)
    var pitch: String,

    @Column(columnDefinition = "TEXT")
    var description: String? = null,

    var stage: String = "Idea",
    var industry: String = "Technology",
    var websiteUrl: String? = null,
    var logoUrl: String? = null,
    var bannerUrl: String? = null,
    var teamSize: Int = 1,
    var fundingRaised: String? = null,

    @Column(nullable = false)
    val createdAt: Instant = Instant.now(),

    @Column(nullable = false)
    var updatedAt: Instant = Instant.now(),

    var deletedAt: Instant? = null
)

@Entity
@Table(name = "startup_members")
data class StartupMemberEntity(
    @Id
    val id: UUID = UUID.randomUUID(),

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "startup_id", nullable = false)
    val startup: StartupEntity,

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "profile_id", nullable = false)
    val profile: ProfileEntity,

    var roleTitle: String = "Co-founder / Member",
    var isAdmin: Boolean = false,

    @Column(nullable = false)
    val joinedAt: Instant = Instant.now()
)

@Entity
@Table(name = "startup_media")
data class StartupMediaEntity(
    @Id
    val id: UUID = UUID.randomUUID(),

    @Column(nullable = false)
    val startupId: UUID,

    @Column(nullable = false)
    val mediaUrl: String,

    var mediaType: String = "image",
    var caption: String? = null,
    var position: Int = 0,

    @Column(nullable = false)
    val createdAt: Instant = Instant.now()
)
