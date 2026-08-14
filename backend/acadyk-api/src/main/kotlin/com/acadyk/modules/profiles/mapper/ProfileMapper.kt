package com.acadyk.modules.profiles.mapper

import com.acadyk.modules.profiles.dto.*
import com.acadyk.modules.profiles.entity.*
import org.springframework.stereotype.Component

@Component
class ProfileMapper {

    fun toResponse(entity: ProfileEntity): ProfileResponse {
        return ProfileResponse(
            id = entity.id,
            username = entity.username,
            fullName = entity.fullName,
            email = entity.email,
            headline = entity.headline,
            bio = entity.bio,
            collegeName = entity.collegeName,
            major = entity.major,
            graduationYear = entity.graduationYear,
            location = entity.location,
            profilePhotoUrl = entity.profilePhotoUrl,
            coverPhotoUrl = entity.coverPhotoUrl,
            statusEmoji = entity.statusEmoji,
            statusText = entity.statusText,
            isPrivate = entity.isPrivate,
            followersCount = entity.followersCount,
            followingCount = entity.followingCount,
            connectionsCount = entity.connectionsCount,
            createdAt = entity.createdAt,
            updatedAt = entity.updatedAt
        )
    }

    fun toDto(entity: EducationEntity): EducationDto = EducationDto(
        id = entity.id,
        institution = entity.institution,
        degree = entity.degree,
        fieldOfStudy = entity.fieldOfStudy,
        startDate = entity.startDate,
        endDate = entity.endDate,
        gradeOrGpa = entity.gradeOrGpa,
        activities = entity.activities
    )

    fun toDto(entity: ExperienceEntity): ExperienceDto = ExperienceDto(
        id = entity.id,
        title = entity.title,
        companyName = entity.companyName,
        employmentType = entity.employmentType,
        location = entity.location,
        isCurrent = entity.isCurrent,
        startDate = entity.startDate,
        endDate = entity.endDate,
        description = entity.description
    )

    fun toDto(entity: CertificateEntity): CertificateDto = CertificateDto(
        id = entity.id,
        name = entity.name,
        issuingOrganization = entity.issuingOrganization,
        issueDate = entity.issueDate,
        expirationDate = entity.expirationDate,
        credentialId = entity.credentialId,
        credentialUrl = entity.credentialUrl
    )

    fun toDto(entity: ResumeEntity): ResumeDto = ResumeDto(
        id = entity.id,
        title = entity.title,
        fileUrl = entity.fileUrl,
        isPrimary = entity.isPrimary,
        fileSizeBytes = entity.fileSizeBytes
    )
}
