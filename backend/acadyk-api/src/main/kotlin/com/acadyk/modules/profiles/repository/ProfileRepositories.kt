package com.acadyk.modules.profiles.repository

import com.acadyk.modules.profiles.entity.*
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.Optional
import java.util.UUID

@Repository
interface ProfileRepository : JpaRepository<ProfileEntity, UUID> {
    fun findByEmail(email: String): Optional<ProfileEntity>
    fun findByUsername(username: String): Optional<ProfileEntity>
    fun findByFullNameContainingIgnoreCaseAndDeletedAtIsNull(name: String, pageable: Pageable): Page<ProfileEntity>
    fun findByFullNameContainingIgnoreCaseAndDeletedAtIsNull(name: String): List<ProfileEntity>
    fun findByIdAndDeletedAtIsNull(id: UUID): Optional<ProfileEntity>
}

@Repository interface EducationRepository : JpaRepository<EducationEntity, UUID> { fun findAllByProfileIdOrderByStartDateDesc(profileId: UUID): List<EducationEntity> }
@Repository interface ExperienceRepository : JpaRepository<ExperienceEntity, UUID> { fun findAllByProfileIdOrderByStartDateDesc(profileId: UUID): List<ExperienceEntity> }
@Repository interface CertificateRepository : JpaRepository<CertificateEntity, UUID> { fun findAllByProfileIdOrderByIssueDateDesc(profileId: UUID): List<CertificateEntity> }
@Repository interface AchievementRepository : JpaRepository<AchievementEntity, UUID> { fun findAllByProfileId(profileId: UUID): List<AchievementEntity> }
@Repository interface ResponsibilityRepository : JpaRepository<ResponsibilityEntity, UUID> { fun findAllByProfileId(profileId: UUID): List<ResponsibilityEntity> }
@Repository interface ResumeRepository : JpaRepository<ResumeEntity, UUID> { fun findAllByProfileId(profileId: UUID): List<ResumeEntity> }
