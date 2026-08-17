package com.acadyk.modules.users.entity

import com.acadyk.security.Role
import jakarta.persistence.*
import org.hibernate.annotations.JdbcTypeCode
import org.hibernate.type.SqlTypes
import java.time.Instant
import java.util.UUID

enum class AccountStatus {
    ACTIVE,
    PENDING_VERIFICATION,
    SUSPENDED,
    INACTIVE
}

@Entity
@Table(name = "users")
data class UserEntity(
    @Id
    val id: UUID = UUID.randomUUID(),

    @Column(name = "firebase_uid", nullable = false, unique = true)
    var firebaseUid: String,

    @JdbcTypeCode(SqlTypes.OTHER)
    @Column(nullable = false, unique = true)
    var email: String,

    @JdbcTypeCode(SqlTypes.OTHER)
    @Column(name = "college_email", unique = true)
    var collegeEmail: String? = null,

    @Column(name = "enrollment_number", unique = true)
    var enrollmentNumber: String? = null,

    var degree: String = "B.Tech",

    var branch: String? = null,

    @Column(name = "joining_year")
    var joiningYear: Int? = null,

    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Enumerated(EnumType.STRING)
    @Column(name = "role", nullable = false)
    var role: Role = Role.STUDENT,

    @Enumerated(EnumType.STRING)
    @Column(name = "account_status", nullable = false)
    var accountStatus: AccountStatus = AccountStatus.ACTIVE,

    @Column(name = "is_active", nullable = false)
    var isActive: Boolean = true,

    @Column(name = "is_email_verified", nullable = false)
    var isEmailVerified: Boolean = true,

    @Column(name = "profile_completed", nullable = false)
    var profileCompleted: Boolean = false,

    @Column(name = "auth_provider", nullable = false)
    var authProvider: String = "FIREBASE_GOOGLE",

    @Column(name = "first_login_at")
    var firstLoginAt: Instant? = null,

    @Column(name = "last_login_at")
    var lastLoginAt: Instant? = null,

    @Column(name = "last_sign_in_at")
    var lastSignInAt: Instant? = null,

    @Column(name = "created_at", nullable = false)
    val createdAt: Instant = Instant.now(),

    @Column(name = "updated_at", nullable = false)
    var updatedAt: Instant = Instant.now(),

    @Column(name = "deleted_at")
    var deletedAt: Instant? = null
)

@Entity
@Table(name = "auth_audit_logs")
data class AuthAuditLogEntity(
    @Id
    val id: UUID = UUID.randomUUID(),

    @Column(name = "firebase_uid")
    var firebaseUid: String? = null,

    @Column(name = "user_id")
    var userId: UUID? = null,

    @Column(nullable = false)
    var email: String,

    @Column(name = "event_type", nullable = false)
    var eventType: String,

    @Column(nullable = false)
    var success: Boolean,

    @Column(name = "failure_reason")
    var failureReason: String? = null,

    @Column(name = "device_info")
    var deviceInfo: String? = null,

    @Column(name = "app_version")
    var appVersion: String? = null,

    @Column(name = "ip_address")
    var ipAddress: String? = null,

    @Column(name = "created_at", nullable = false)
    val createdAt: Instant = Instant.now()
)
