package com.acadyk.modules.users.repository

import com.acadyk.modules.users.entity.AuthAuditLogEntity
import com.acadyk.modules.users.entity.UserEntity
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.Optional
import java.util.UUID

@Repository
interface UserRepository : JpaRepository<UserEntity, UUID> {
    fun findByFirebaseUid(firebaseUid: String): Optional<UserEntity>
    fun findByEmail(email: String): Optional<UserEntity>
    fun findByCollegeEmail(collegeEmail: String): Optional<UserEntity>
    fun findByEnrollmentNumber(enrollmentNumber: String): Optional<UserEntity>
    fun existsByFirebaseUid(firebaseUid: String): Boolean
    fun existsByEmail(email: String): Boolean
    fun existsByCollegeEmail(collegeEmail: String): Boolean
    fun existsByEnrollmentNumber(enrollmentNumber: String): Boolean
}

@Repository
interface AuthAuditLogRepository : JpaRepository<AuthAuditLogEntity, UUID> {
    fun findAllByFirebaseUidOrderByCreatedAtDesc(firebaseUid: String): List<AuthAuditLogEntity>
    fun findAllByEmailOrderByCreatedAtDesc(email: String): List<AuthAuditLogEntity>
}
