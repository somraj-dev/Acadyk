package com.acadyk.modules.clubs.entity

import com.acadyk.modules.profiles.entity.ProfileEntity
import jakarta.persistence.*
import org.hibernate.annotations.JdbcTypeCode
import org.hibernate.type.SqlTypes
import java.time.Instant
import java.util.UUID

@Entity
@Table(name = "clubs")
data class ClubEntity(
    @Id
    val id: UUID = UUID.randomUUID(),

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "creator_id")
    val creator: ProfileEntity? = null,

    var collegeName: String? = null,

    @Column(nullable = false)
    var name: String,

    @JdbcTypeCode(SqlTypes.OTHER)
    @Column(nullable = false, unique = true)
    var slug: String,

    @Column(columnDefinition = "TEXT")
    var description: String? = null,

    var category: String = "Technical",
    var logoUrl: String? = null,
    var bannerUrl: String? = null,
    var membersCount: Int = 1,

    @Column(nullable = false)
    val createdAt: Instant = Instant.now(),

    @Column(nullable = false)
    var updatedAt: Instant = Instant.now(),

    var deletedAt: Instant? = null
)

@Entity
@Table(name = "club_members")
data class ClubMemberEntity(
    @Id
    val id: UUID = UUID.randomUUID(),

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "club_id", nullable = false)
    val club: ClubEntity,

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "profile_id", nullable = false)
    val profile: ProfileEntity,

    var role: String = "MEMBER",

    @Column(nullable = false)
    val joinedAt: Instant = Instant.now()
)
