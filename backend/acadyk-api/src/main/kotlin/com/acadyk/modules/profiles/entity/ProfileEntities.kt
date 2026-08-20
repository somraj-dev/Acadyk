package com.acadyk.modules.profiles.entity

import org.hibernate.annotations.JdbcTypeCode
import org.hibernate.type.SqlTypes

import jakarta.persistence.*
import java.time.Instant
import java.time.LocalDate
import java.util.UUID

@Entity
@Table(name = "profiles")
data class ProfileEntity(
    @Id
    val id: UUID = UUID.randomUUID(),

    @Column(name = "user_id", nullable = false, unique = true)
    var userId: UUID = id,

    @Column(nullable = false, unique = true)
    var username: String,

    @Column(nullable = false)
    var fullName: String,

    @Transient
    var email: String = "",

    var headline: String? = null,
    var bio: String? = null,
    var collegeName: String? = null,
    var major: String? = null,
    var graduationYear: Int? = null,
    var location: String? = null,
    var profilePhotoUrl: String? = null,
    var coverPhotoUrl: String? = null,
    var statusEmoji: String? = null,
    var statusText: String? = null,
    var isPrivate: Boolean = false,
    var followersCount: Int = 0,
    var followingCount: Int = 0,
    var connectionsCount: Int = 0,

    @Column(nullable = false)
    val createdAt: Instant = Instant.now(),

    @Column(nullable = false)
    var updatedAt: Instant = Instant.now(),

    var deletedAt: Instant? = null
)

@Entity
@Table(name = "education")
data class EducationEntity(
    @Id
    val id: UUID = UUID.randomUUID(),
    val profileId: UUID,
    var institution: String,
    var degree: String,
    var fieldOfStudy: String? = null,
    var startDate: LocalDate = LocalDate.now(),
    var endDate: LocalDate? = null,
    var gradeOrGpa: String? = null,
    var activities: String? = null,
    val createdAt: Instant = Instant.now()
)

@Entity
@Table(name = "experiences")
data class ExperienceEntity(
    @Id
    val id: UUID = UUID.randomUUID(),
    val profileId: UUID,
    var title: String,
    var companyName: String,
    var employmentType: String = "Full-time",
    var location: String? = null,
    var isCurrent: Boolean = false,
    var startDate: LocalDate = LocalDate.now(),
    var endDate: LocalDate? = null,
    var description: String? = null,
    val createdAt: Instant = Instant.now()
)

@Entity
@Table(name = "certificates")
data class CertificateEntity(
    @Id
    val id: UUID = UUID.randomUUID(),
    val profileId: UUID,
    var name: String,
    var issuingOrganization: String,
    var issueDate: LocalDate = LocalDate.now(),
    var expirationDate: LocalDate? = null,
    var credentialId: String? = null,
    var credentialUrl: String? = null,
    val createdAt: Instant = Instant.now()
)

@Entity
@Table(name = "achievements")
data class AchievementEntity(
    @Id
    val id: UUID = UUID.randomUUID(),
    val profileId: UUID,
    var title: String,
    var issuer: String? = null,
    var dateAchieved: LocalDate? = null,
    var description: String? = null,
    val createdAt: Instant = Instant.now()
)

@Entity
@Table(name = "responsibilities")
data class ResponsibilityEntity(
    @Id
    val id: UUID = UUID.randomUUID(),
    val profileId: UUID,
    var title: String,
    var organization: String,
    var description: String? = null,
    var startDate: LocalDate? = null,
    var endDate: LocalDate? = null,
    val createdAt: Instant = Instant.now()
)

@Entity
@Table(name = "resumes")
data class ResumeEntity(
    @Id
    val id: UUID = UUID.randomUUID(),
    val profileId: UUID,
    var title: String = "My Resume",
    var fileUrl: String,
    var isPrimary: Boolean = false,
    var fileSizeBytes: Long? = null,
    val createdAt: Instant = Instant.now()
)
