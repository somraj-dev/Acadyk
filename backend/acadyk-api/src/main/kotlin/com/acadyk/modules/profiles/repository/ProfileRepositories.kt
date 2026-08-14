package com.acadyk.modules.profiles.repository

import com.acadyk.modules.profiles.entity.*
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.Optional

@Repository
interface ProfileRepository : JpaRepository<ProfileEntity, String> {
    fun findByEmail(email: String): Optional<ProfileEntity>
    fun findByUsername(username: String): Optional<ProfileEntity>
    fun findByFullNameContainingIgnoreCaseAndDeletedAtIsNull(name: String, pageable: Pageable): Page<ProfileEntity>
    fun findByFullNameContainingIgnoreCaseAndDeletedAtIsNull(name: String): List<ProfileEntity>
    fun findByIdAndDeletedAtIsNull(id: String): Optional<ProfileEntity>
}

@Repository interface EducationRepository : JpaRepository<EducationEntity, String> { fun findAllByProfileIdOrderByStartDateDesc(profileId: String): List<EducationEntity> }
@Repository interface ExperienceRepository : JpaRepository<ExperienceEntity, String> { fun findAllByProfileIdOrderByStartDateDesc(profileId: String): List<ExperienceEntity> }
@Repository interface CertificateRepository : JpaRepository<CertificateEntity, String> { fun findAllByProfileIdOrderByIssueDateDesc(profileId: String): List<CertificateEntity> }
@Repository interface AchievementRepository : JpaRepository<AchievementEntity, String> { fun findAllByProfileId(profileId: String): List<AchievementEntity> }
@Repository interface ResponsibilityRepository : JpaRepository<ResponsibilityEntity, String> { fun findAllByProfileId(profileId: String): List<ResponsibilityEntity> }
@Repository interface ResumeRepository : JpaRepository<ResumeEntity, String> { fun findAllByProfileId(profileId: String): List<ResumeEntity> }
