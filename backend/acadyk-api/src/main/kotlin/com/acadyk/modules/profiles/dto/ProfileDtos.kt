package com.acadyk.modules.profiles.dto

import jakarta.validation.constraints.Size
import java.time.Instant
import java.time.LocalDate

data class UpdateProfileRequest(
    @field:Size(max = 100, message = "Full name cannot exceed 100 characters")
    val fullName: String? = null,

    @field:Size(max = 255, message = "Headline cannot exceed 255 characters")
    val headline: String? = null,

    @field:Size(max = 3000, message = "Bio cannot exceed 3000 characters")
    val bio: String? = null,

    val collegeName: String? = null,
    val major: String? = null,
    val graduationYear: Int? = null,
    val location: String? = null,
    val profilePhotoUrl: String? = null,
    val coverPhotoUrl: String? = null,
    val statusEmoji: String? = null,
    val statusText: String? = null
)

data class ProfileResponse(
    val id: String,
    val username: String,
    val fullName: String,
    val email: String,
    val headline: String?,
    val bio: String?,
    val collegeName: String?,
    val major: String?,
    val graduationYear: Int?,
    val location: String?,
    val profilePhotoUrl: String?,
    val coverPhotoUrl: String?,
    val statusEmoji: String?,
    val statusText: String?,
    val isPrivate: Boolean,
    val followersCount: Int,
    val followingCount: Int,
    val connectionsCount: Int,
    val createdAt: Instant,
    val updatedAt: Instant
)

data class EducationDto(
    val id: String?,
    val institution: String,
    val degree: String,
    val fieldOfStudy: String?,
    val startDate: LocalDate,
    val endDate: LocalDate?,
    val gradeOrGpa: String?,
    val activities: String?
)

data class ExperienceDto(
    val id: String?,
    val title: String,
    val companyName: String,
    val employmentType: String?,
    val location: String?,
    val isCurrent: Boolean,
    val startDate: LocalDate,
    val endDate: LocalDate?,
    val description: String?
)

data class CertificateDto(
    val id: String?,
    val name: String,
    val issuingOrganization: String,
    val issueDate: LocalDate,
    val expirationDate: LocalDate?,
    val credentialId: String?,
    val credentialUrl: String?
)

data class ResumeDto(
    val id: String?,
    val title: String,
    val fileUrl: String,
    val isPrimary: Boolean,
    val fileSizeBytes: Long?
)
