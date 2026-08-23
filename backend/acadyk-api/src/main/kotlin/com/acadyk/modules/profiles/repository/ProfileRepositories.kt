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
    fun findByUsername(username: String): Optional<ProfileEntity>
    fun findByUserId(userId: UUID): Optional<ProfileEntity>
    fun findByUserIdAndDeletedAtIsNull(userId: UUID): Optional<ProfileEntity>
    fun findByFullNameContainingIgnoreCaseAndDeletedAtIsNull(name: String, pageable: Pageable): Page<ProfileEntity>
    fun findByIdAndDeletedAtIsNull(id: UUID): Optional<ProfileEntity>
    fun findAllByUserIdIn(userIds: Collection<UUID>): List<ProfileEntity>

    @org.springframework.data.jpa.repository.Query("""
        SELECT p FROM ProfileEntity p, com.acadyk.modules.users.entity.UserEntity u
        WHERE p.userId = u.id 
          AND p.deletedAt IS NULL 
          AND u.deletedAt IS NULL
          AND u.isActive = TRUE
          AND u.role IN :allowedRoles
          AND (:currentUserId IS NULL OR (p.userId != :currentUserId AND p.id != :currentUserId))
          AND (
            LOWER(p.fullName) LIKE LOWER(CONCAT('%', :query, '%')) OR
            LOWER(p.username) LIKE LOWER(CONCAT('%', :query, '%')) OR
            (p.headline IS NOT NULL AND LOWER(p.headline) LIKE LOWER(CONCAT('%', :query, '%'))) OR
            (u.email IS NOT NULL AND LOWER(u.email) LIKE LOWER(CONCAT('%', :query, '%'))) OR
            (u.collegeEmail IS NOT NULL AND LOWER(u.collegeEmail) LIKE LOWER(CONCAT('%', :query, '%'))) OR
            (u.enrollmentNumber IS NOT NULL AND (
                LOWER(u.enrollmentNumber) LIKE LOWER(CONCAT('%', :query, '%')) OR
                LOWER(REPLACE(u.enrollmentNumber, 'O', '0')) LIKE LOWER(CONCAT('%', REPLACE(:query, 'O', '0'), '%')) OR
                LOWER(REPLACE(u.enrollmentNumber, '0', 'O')) LIKE LOWER(CONCAT('%', REPLACE(:query, '0', 'O'), '%'))
            )) OR
            (u.branch IS NOT NULL AND LOWER(u.branch) LIKE LOWER(CONCAT('%', :query, '%'))) OR
            (u.department IS NOT NULL AND LOWER(u.department) LIKE LOWER(CONCAT('%', :query, '%')))
        )
    """)
    fun searchProfilesMultiField(
        @org.springframework.data.repository.query.Param("query") query: String,
        @org.springframework.data.repository.query.Param("allowedRoles") allowedRoles: List<com.acadyk.security.Role>,
        @org.springframework.data.repository.query.Param("currentUserId") currentUserId: UUID?,
        pageable: Pageable
    ): Page<ProfileEntity>

    @org.springframework.data.jpa.repository.Query("""
        SELECT p FROM ProfileEntity p, com.acadyk.modules.users.entity.UserEntity u
        WHERE p.userId = u.id 
          AND p.deletedAt IS NULL 
          AND u.deletedAt IS NULL
          AND u.isActive = TRUE
          AND u.role IN :allowedRoles
          AND (:currentUserId IS NULL OR (p.userId != :currentUserId AND p.id != :currentUserId))
    """)
    fun findAllDiscoverable(
        @org.springframework.data.repository.query.Param("allowedRoles") allowedRoles: List<com.acadyk.security.Role>,
        @org.springframework.data.repository.query.Param("currentUserId") currentUserId: UUID?,
        pageable: Pageable
    ): Page<ProfileEntity>
}

@Repository interface EducationRepository : JpaRepository<EducationEntity, UUID> { fun findAllByProfileIdOrderByStartDateDesc(profileId: UUID): List<EducationEntity> }
@Repository interface ExperienceRepository : JpaRepository<ExperienceEntity, UUID> { fun findAllByProfileIdOrderByStartDateDesc(profileId: UUID): List<ExperienceEntity> }
@Repository interface CertificateRepository : JpaRepository<CertificateEntity, UUID> { fun findAllByProfileIdOrderByIssueDateDesc(profileId: UUID): List<CertificateEntity> }
@Repository interface AchievementRepository : JpaRepository<AchievementEntity, UUID> { fun findAllByProfileId(profileId: UUID): List<AchievementEntity> }
@Repository interface ResponsibilityRepository : JpaRepository<ResponsibilityEntity, UUID> { fun findAllByProfileId(profileId: UUID): List<ResponsibilityEntity> }
@Repository interface ResumeRepository : JpaRepository<ResumeEntity, UUID> { fun findAllByProfileId(profileId: UUID): List<ResumeEntity> }
