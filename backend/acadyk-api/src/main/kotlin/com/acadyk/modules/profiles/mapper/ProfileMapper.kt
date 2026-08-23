package com.acadyk.modules.profiles.mapper

import com.acadyk.modules.profiles.dto.*
import com.acadyk.modules.profiles.entity.*
import com.acadyk.modules.users.repository.UserRepository
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Component

@Component
class ProfileMapper(
    @Autowired(required = false)
    private val userRepository: UserRepository? = null
) {

    fun toResponse(
        entity: ProfileEntity,
        postCount: Int = 0,
        isFollowing: Boolean = false,
        isFollowedBy: Boolean = false
    ): ProfileResponse {
        val userEntity = runCatching { userRepository?.findById(entity.userId)?.orElse(null) }.getOrNull()

        val profileEmail = entity.email?.takeIf { it.isNotBlank() }
            ?: userEntity?.collegeEmail
            ?: userEntity?.email
            ?: ""

        return ProfileResponse(
            id = entity.id.toString(),
            username = entity.username,
            fullName = entity.fullName,
            email = profileEmail,
            headline = entity.headline,
            bio = entity.bio,
            collegeName = entity.collegeName ?: "Madhav Institute of Technology & Science, Gwalior",
            major = entity.major ?: userEntity?.branch ?: userEntity?.department ?: "AIML",
            graduationYear = entity.graduationYear ?: userEntity?.joiningYear?.plus(4),
            location = entity.location ?: "Gwalior, Madhya Pradesh",
            profilePhotoUrl = entity.profilePhotoUrl,
            coverPhotoUrl = entity.coverPhotoUrl,
            statusEmoji = entity.statusEmoji,
            statusText = entity.statusText,
            isPrivate = entity.isPrivate,
            followersCount = entity.followersCount,
            followingCount = entity.followingCount,
            connectionsCount = entity.connectionsCount,
            postCount = postCount,
            isFollowing = isFollowing,
            isFollowedBy = isFollowedBy,
            enrollmentNumber = userEntity?.enrollmentNumber,
            degree = userEntity?.degree ?: "B.Tech",
            branch = userEntity?.branch ?: entity.major ?: "AIML",
            department = userEntity?.department ?: "Artificial Intelligence & Machine Learning",
            accountStatus = userEntity?.accountStatus?.name ?: "ACTIVE",
            phone = userEntity?.phone,
            createdAt = entity.createdAt,
            updatedAt = entity.updatedAt
        )
    }

    fun toDto(entity: EducationEntity): EducationDto = EducationDto(
        id = entity.id.toString(),
        institution = entity.institution,
        degree = entity.degree,
        fieldOfStudy = entity.fieldOfStudy,
        startDate = entity.startDate,
        endDate = entity.endDate,
        gradeOrGpa = entity.gradeOrGpa,
        activities = entity.activities
    )

    fun toDto(entity: ExperienceEntity): ExperienceDto = ExperienceDto(
        id = entity.id.toString(),
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
        id = entity.id.toString(),
        name = entity.name,
        issuingOrganization = entity.issuingOrganization,
        issueDate = entity.issueDate,
        expirationDate = entity.expirationDate,
        credentialId = entity.credentialId,
        credentialUrl = entity.credentialUrl
    )

    fun toDto(entity: ResumeEntity): ResumeDto = ResumeDto(
        id = entity.id.toString(),
        title = entity.title,
        fileUrl = entity.fileUrl,
        isPrimary = entity.isPrimary,
        fileSizeBytes = entity.fileSizeBytes
    )
}
