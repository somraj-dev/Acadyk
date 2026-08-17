package com.acadyk.modules.profiles.service

import com.acadyk.common.PageResponse
import com.acadyk.common.ResourceNotFoundException
import com.acadyk.common.toUUID
import com.acadyk.modules.profiles.dto.*
import com.acadyk.modules.profiles.entity.*
import com.acadyk.modules.profiles.mapper.ProfileMapper
import com.acadyk.modules.profiles.repository.*
import com.acadyk.security.CurrentUserProvider
import org.springframework.data.domain.PageRequest
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.util.UUID

@Service
@Transactional
class ProfileService(
    private val profileRepository: ProfileRepository,
    private val educationRepository: EducationRepository,
    private val experienceRepository: ExperienceRepository,
    private val certificateRepository: CertificateRepository,
    private val resumeRepository: ResumeRepository,
    private val profileMapper: ProfileMapper,
    private val currentUserProvider: CurrentUserProvider
) {

    @Transactional(readOnly = true)
    fun getProfileById(id: UUID): ProfileResponse {
        val profile = profileRepository.findByIdAndDeletedAtIsNull(id)
            .orElseThrow { ResourceNotFoundException("Profile with id $id not found") }
        return profileMapper.toResponse(profile)
    }

    @Transactional(readOnly = true)
    fun getProfileById(id: String): ProfileResponse = getProfileById(id.toUUID())

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

    @Transactional(readOnly = true)
    fun searchProfiles(query: String, page: Int, size: Int): PageResponse<ProfileResponse> {
        val pageable = PageRequest.of(page, size)
        val result = profileRepository.findByFullNameContainingIgnoreCaseAndDeletedAtIsNull(query, pageable)
        return PageResponse.from(result, profileMapper::toResponse)
    }

    @Transactional(readOnly = true)
    fun getEducation(profileId: UUID): List<EducationDto> =
        educationRepository.findAllByProfileIdOrderByStartDateDesc(profileId).map(profileMapper::toDto)

    @Transactional(readOnly = true)
    fun getEducation(profileId: String): List<EducationDto> = getEducation(profileId.toUUID())

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
    fun getExperiences(profileId: String): List<ExperienceDto> = getExperiences(profileId.toUUID())

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
    fun getCertificates(profileId: String): List<CertificateDto> = getCertificates(profileId.toUUID())

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
    fun getResumes(profileId: String): List<ResumeDto> = getResumes(profileId.toUUID())

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
