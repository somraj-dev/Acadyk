package com.acadyk.modules.profiles.service

import com.acadyk.common.PageResponse
import com.acadyk.common.ResourceNotFoundException
import com.acadyk.common.toUUID
import com.acadyk.modules.connections.repository.FollowRepository
import com.acadyk.modules.posts.repository.PostRepository
import com.acadyk.modules.profiles.dto.*
import com.acadyk.modules.profiles.entity.*
import com.acadyk.modules.profiles.mapper.ProfileMapper
import com.acadyk.modules.profiles.repository.*
import com.acadyk.security.CurrentUserProvider
import com.acadyk.common.toUUIDOrNull
import com.acadyk.modules.users.repository.UserRepository
import org.springframework.data.domain.PageRequest
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.util.UUID

@Service
@Transactional
class ProfileService(
    private val profileRepository: ProfileRepository,
    private val userRepository: UserRepository,
    private val educationRepository: EducationRepository,
    private val experienceRepository: ExperienceRepository,
    private val certificateRepository: CertificateRepository,
    private val resumeRepository: ResumeRepository,
    private val postRepository: PostRepository,
    private val followRepository: FollowRepository,
    private val profileMapper: ProfileMapper,
    private val currentUserProvider: CurrentUserProvider
) {

    fun resolveProfileId(identifier: String): UUID {
        val trimmed = identifier.trim()
        if (trimmed.equals("me", ignoreCase = true) || trimmed.equals("self", ignoreCase = true)) {
            return currentUserProvider.getCurrentUserId()
        }

        // 1. Direct UUID match
        val directUuid = trimmed.toUUIDOrNull()
        if (directUuid != null) {
            if (profileRepository.existsById(directUuid)) {
                return directUuid
            }
            val byUserId = profileRepository.findByUserId(directUuid)
            if (byUserId.isPresent) {
                return byUserId.get().id
            }
            return directUuid
        }

        // 2. Firebase UID match
        val byFirebase = userRepository.findByFirebaseUid(trimmed)
        if (byFirebase.isPresent) {
            val userProfile = profileRepository.findByUserId(byFirebase.get().id)
            if (userProfile.isPresent) return userProfile.get().id
            return byFirebase.get().id
        }

        // 3. Enrollment number match
        val byEnrollment = userRepository.findByEnrollmentNumber(trimmed)
        if (byEnrollment.isPresent) {
            val userProfile = profileRepository.findByUserId(byEnrollment.get().id)
            if (userProfile.isPresent) return userProfile.get().id
            return byEnrollment.get().id
        }

        // 4. Username match
        val byUsername = profileRepository.findByUsername(trimmed)
        if (byUsername.isPresent) {
            return byUsername.get().id
        }

        // 5. Email match
        val byEmail = userRepository.findByEmail(trimmed)
            .or { userRepository.findByCollegeEmail(trimmed) }
        if (byEmail.isPresent) {
            val userProfile = profileRepository.findByUserId(byEmail.get().id)
            if (userProfile.isPresent) return userProfile.get().id
            return byEmail.get().id
        }

        // 6. Handle mock-firebase-uid- prefix in dev mode
        val cleanPrefix = trimmed.removePrefix("mock-firebase-uid-").trim()
        if (cleanPrefix != trimmed) {
            val byClean = userRepository.findByEmail("$cleanPrefix@mitsgwl.ac.in")
                .or { userRepository.findByCollegeEmail("$cleanPrefix@mitsgwl.ac.in") }
                .or { userRepository.findByEnrollmentNumber(cleanPrefix) }
            if (byClean.isPresent) {
                val userProfile = profileRepository.findByUserId(byClean.get().id)
                if (userProfile.isPresent) return userProfile.get().id
                return byClean.get().id
            }
        }

        throw ResourceNotFoundException("Profile not found for identifier: $identifier")
    }

    @Transactional(readOnly = true)
    fun getProfileById(id: UUID): ProfileResponse {
        val profile = profileRepository.findByIdAndDeletedAtIsNull(id)
            .orElseThrow { ResourceNotFoundException("Profile with id $id not found") }

        val postCount = postRepository.countByAuthorIdAndDeletedAtIsNull(id).toInt()

        var isFollowing = false
        var isFollowedBy = false
        try {
            val currentUserId = currentUserProvider.getCurrentUserId()
            if (currentUserId != id) {
                isFollowing = followRepository.existsByFollowerIdAndFollowingId(currentUserId, id)
                isFollowedBy = followRepository.existsByFollowerIdAndFollowingId(id, currentUserId)
            }
        } catch (_: Exception) {
            // Unauthenticated or background context
        }

        return profileMapper.toResponse(
            entity = profile,
            postCount = postCount,
            isFollowing = isFollowing,
            isFollowedBy = isFollowedBy
        )
    }

    @Transactional(readOnly = true)
    fun getProfileById(id: String): ProfileResponse = getProfileById(resolveProfileId(id))

    fun updateMyProfile(request: UpdateProfileRequest): ProfileResponse {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val profile = profileRepository.findById(currentUserId).orElseGet {
            ProfileEntity(
                id = currentUserId,
                username = "user_${currentUserId.toString().take(8)}",
                fullName = request.fullName ?: "Acadyk User",
                email = currentUserProvider.getCurrentUserEmail()
            )
        }

        request.fullName?.let { profile.fullName = it }
        request.headline?.let { profile.headline = it }
        request.bio?.let { profile.bio = it }
        request.collegeName?.let { profile.collegeName = it }
        request.major?.let { profile.major = it }
        request.graduationYear?.let { profile.graduationYear = it }
        request.location?.let { profile.location = it }
        request.profilePhotoUrl?.let { profile.profilePhotoUrl = it }
        request.coverPhotoUrl?.let { profile.coverPhotoUrl = it }
        request.statusEmoji?.let { profile.statusEmoji = it }
        request.statusText?.let { profile.statusText = it }
        profile.updatedAt = Instant.now()

        val saved = profileRepository.save(profile)
        return profileMapper.toResponse(saved)
    }

    private val discoverableRoles = listOf(com.acadyk.security.Role.STUDENT, com.acadyk.security.Role.FACULTY, com.acadyk.security.Role.COMPANY)

    @Transactional(readOnly = true)
    fun searchProfiles(query: String, page: Int, size: Int): PageResponse<ProfileResponse> {
        val trimmed = query.trim()
        val pageable = PageRequest.of(page, size)
        val currentUserId = runCatching { currentUserProvider.getCurrentUserId() }.getOrNull()

        val result = if (trimmed.isNotBlank()) {
            profileRepository.searchProfilesMultiField(trimmed, discoverableRoles, currentUserId, pageable)
        } else {
            profileRepository.findAllDiscoverable(discoverableRoles, currentUserId, pageable)
        }

        return PageResponse.from(result) { entity ->
            val isFollowing = if (currentUserId != null && currentUserId != entity.id) {
                followRepository.existsByFollowerIdAndFollowingId(currentUserId, entity.id)
            } else false
            val isFollowedBy = if (currentUserId != null && currentUserId != entity.id) {
                followRepository.existsByFollowerIdAndFollowingId(entity.id, currentUserId)
            } else false
            profileMapper.toResponse(
                entity = entity,
                postCount = postRepository.countByAuthorIdAndDeletedAtIsNull(entity.id).toInt(),
                isFollowing = isFollowing,
                isFollowedBy = isFollowedBy
            )
        }
    }

    @Transactional(readOnly = true)
    fun getEducation(profileId: UUID): List<EducationDto> =
        educationRepository.findAllByProfileIdOrderByStartDateDesc(profileId).map(profileMapper::toDto)

    @Transactional(readOnly = true)
    fun getEducation(profileId: String): List<EducationDto> = getEducation(resolveProfileId(profileId))

    fun addEducation(dto: EducationDto): EducationDto {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val entity = EducationEntity(
            profileId = currentUserId,
            institution = dto.institution,
            degree = dto.degree,
            fieldOfStudy = dto.fieldOfStudy,
            startDate = dto.startDate,
            endDate = dto.endDate,
            gradeOrGpa = dto.gradeOrGpa,
            activities = dto.activities
        )
        return profileMapper.toDto(educationRepository.save(entity))
    }

    @Transactional(readOnly = true)
    fun getExperiences(profileId: UUID): List<ExperienceDto> =
        experienceRepository.findAllByProfileIdOrderByStartDateDesc(profileId).map(profileMapper::toDto)

    @Transactional(readOnly = true)
    fun getExperiences(profileId: String): List<ExperienceDto> = getExperiences(resolveProfileId(profileId))

    fun addExperience(dto: ExperienceDto): ExperienceDto {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val entity = ExperienceEntity(
            profileId = currentUserId,
            title = dto.title,
            companyName = dto.companyName,
            employmentType = dto.employmentType ?: "Full-time",
            location = dto.location,
            isCurrent = dto.isCurrent,
            startDate = dto.startDate,
            endDate = dto.endDate,
            description = dto.description
        )
        return profileMapper.toDto(experienceRepository.save(entity))
    }

    @Transactional(readOnly = true)
    fun getCertificates(profileId: UUID): List<CertificateDto> =
        certificateRepository.findAllByProfileIdOrderByIssueDateDesc(profileId).map(profileMapper::toDto)

    @Transactional(readOnly = true)
    fun getCertificates(profileId: String): List<CertificateDto> = getCertificates(resolveProfileId(profileId))

    fun addCertificate(dto: CertificateDto): CertificateDto {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val entity = CertificateEntity(
            profileId = currentUserId,
            name = dto.name,
            issuingOrganization = dto.issuingOrganization,
            issueDate = dto.issueDate,
            expirationDate = dto.expirationDate,
            credentialId = dto.credentialId,
            credentialUrl = dto.credentialUrl
        )
        return profileMapper.toDto(certificateRepository.save(entity))
    }

    @Transactional(readOnly = true)
    fun getResumes(profileId: UUID): List<ResumeDto> =
        resumeRepository.findAllByProfileId(profileId).map(profileMapper::toDto)

    @Transactional(readOnly = true)
    fun getResumes(profileId: String): List<ResumeDto> = getResumes(resolveProfileId(profileId))

    fun addResume(dto: ResumeDto): ResumeDto {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val entity = ResumeEntity(
            profileId = currentUserId,
            title = dto.title,
            fileUrl = dto.fileUrl,
            isPrimary = dto.isPrimary,
            fileSizeBytes = dto.fileSizeBytes
        )
        return profileMapper.toDto(resumeRepository.save(entity))
    }
}
