package com.acadyk.modules.opportunities.entity

import org.hibernate.annotations.JdbcTypeCode
import org.hibernate.type.SqlTypes

import com.acadyk.modules.profiles.entity.ProfileEntity
import com.acadyk.modules.profiles.entity.ResumeEntity
import jakarta.persistence.*
import java.time.Instant
import java.util.UUID

@Entity
@Table(name = "opportunities")
data class OpportunityEntity(
    @Id
    val id: UUID = UUID.randomUUID(),

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "posted_by_id")
    val postedBy: ProfileEntity? = null,

    @Column(nullable = false)
    var companyName: String,

    @Column(nullable = false)
    var title: String,

    @Column(nullable = false, unique = true)
    @JdbcTypeCode(SqlTypes.OTHER)
    var slug: String,

    var opportunityType: String = "INTERNSHIP",

    @Column(columnDefinition = "TEXT", nullable = false)
    var description: String,

    @Column(columnDefinition = "TEXT")
    var requirements: String? = null,

    var location: String? = null,
    var isRemote: Boolean = false,
    var stipendOrSalary: String? = null,
    var deadline: Instant? = null,
    var applyUrl: String? = null,
    var applicationsCount: Int = 0,

    @Column(nullable = false)
    val createdAt: Instant = Instant.now(),

    @Column(nullable = false)
    var updatedAt: Instant = Instant.now(),

    var deletedAt: Instant? = null
)

@Entity
@Table(name = "opportunity_applications")
data class OpportunityApplicationEntity(
    @Id
    val id: UUID = UUID.randomUUID(),

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "opportunity_id", nullable = false)
    val opportunity: OpportunityEntity,

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "profile_id", nullable = false)
    val profile: ProfileEntity,

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "resume_id")
    val resume: ResumeEntity? = null,

    var status: String = "APPLIED",
    var coverNote: String? = null,

    @Column(nullable = false)
    val appliedAt: Instant = Instant.now()
)
