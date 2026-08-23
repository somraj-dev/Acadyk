package com.acadyk.modules.users.repository

import com.acadyk.modules.users.entity.AuthAuditLogEntity
import com.acadyk.modules.users.entity.UserEntity
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.JpaSpecificationExecutor
import org.springframework.stereotype.Repository
import java.util.Optional
import java.util.UUID

@Repository
interface UserRepository : JpaRepository<UserEntity, UUID>, JpaSpecificationExecutor<UserEntity> {
    fun findByFirebaseUid(firebaseUid: String): Optional<UserEntity>
    fun findByEmail(email: String): Optional<UserEntity>
    fun findByCollegeEmail(collegeEmail: String): Optional<UserEntity>
    fun findByEnrollmentNumber(enrollmentNumber: String): Optional<UserEntity>
    fun findByEmployeeId(employeeId: String): Optional<UserEntity>
    fun existsByFirebaseUid(firebaseUid: String): Boolean
    fun existsByEmail(email: String): Boolean
    fun existsByCollegeEmail(collegeEmail: String): Boolean
    fun existsByEnrollmentNumber(enrollmentNumber: String): Boolean
    fun existsByEmployeeId(employeeId: String): Boolean

    fun findAllByDeletedAtIsNullOrderByCreatedAtDesc(): List<UserEntity>
    fun findAllByDeletedAtIsNull(pageable: org.springframework.data.domain.Pageable): org.springframework.data.domain.Page<UserEntity>
    fun countByDeletedAtIsNull(): Long
    fun countByRoleAndDeletedAtIsNull(role: com.acadyk.security.Role): Long
    fun countByAccountStatusAndDeletedAtIsNull(accountStatus: com.acadyk.modules.users.entity.AccountStatus): Long
    fun countByCreatedAtAfterAndDeletedAtIsNull(after: java.time.Instant): Long
}

@Repository
interface AuthAuditLogRepository : JpaRepository<AuthAuditLogEntity, UUID> {
    fun findAllByOrderByCreatedAtDesc(): List<AuthAuditLogEntity>
    fun findAllByFirebaseUidOrderByCreatedAtDesc(firebaseUid: String): List<AuthAuditLogEntity>
    fun findAllByEmailOrderByCreatedAtDesc(email: String): List<AuthAuditLogEntity>
}
