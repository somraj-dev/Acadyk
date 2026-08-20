package com.acadyk.modules.admin.dto

import com.acadyk.modules.users.entity.AccountStatus
import com.acadyk.security.Role
import java.time.Instant
import java.time.LocalDate

data class CreateAdminUserRequest(
    val fullName: String,
    val email: String,
    val role: Role = Role.STUDENT,
    val status: String = "ACTIVE",
    val department: String? = null,
    val enrollmentNumber: String? = null,
    val employeeId: String? = null,
    val course: String? = "B.Tech",
    val branch: String? = null,
    val joiningYear: Int? = null,
    val dateOfBirth: String? = null,
    val fatherName: String? = null,
    val fatherMobile: String? = null,
    val currentAddress: String? = null,
    val phone: String? = null,
    val designation: String? = null,
    val admissionDate: String? = null,
    val registrationDate: String? = null
)

data class UpdateAdminUserRequest(
    val fullName: String? = null,
    val email: String? = null,
    val role: Role? = null,
    val status: String? = null,
    val department: String? = null,
    val enrollmentNumber: String? = null,
    val employeeId: String? = null,
    val course: String? = null,
    val branch: String? = null,
    val joiningYear: Int? = null,
    val dateOfBirth: String? = null,
    val fatherName: String? = null,
    val fatherMobile: String? = null,
    val currentAddress: String? = null,
    val phone: String? = null,
    val designation: String? = null,
    val admissionDate: String? = null,
    val registrationDate: String? = null
)

data class UpdateUserStatusRequest(
    val status: String,
    val reason: String? = null
)

data class SuspendUserRequest(
    val reason: String? = null
)

data class AdminUserResponse(
    val id: String,
    val fullName: String,
    val email: String,
    val role: String,
    val status: String,
    val department: String?,
    val avatarUrl: String?,
    val enrollmentNumber: String?,
    val employeeId: String?,
    val course: String?,
    val branch: String?,
    val joiningYear: Int?,
    val year: Int?,
    val semester: Int?,
    val batch: String?,
    val phone: String?,
    val designation: String?,
    val fatherName: String?,
    val fatherMobile: String?,
    val currentAddress: String?,
    val dateOfBirth: String?,
    val admissionDate: String?,
    val registrationDate: String?,
    val joinedAt: Instant,
    val lastActive: Instant,
    val postsCount: Int = 0,
    val suspensionReason: String? = null,
    val suspendedAt: Instant? = null,
    val suspendedBy: String? = null
)

data class AdminDashboardStatsResponse(
    val totalUsers: Long,
    val activeUsers: Long,
    val totalPosts: Long,
    val totalOpportunities: Long = 0,
    val totalClubs: Long,
    val totalEvents: Long,
    val pendingReports: Long = 0,
    val newUsersToday: Long,
    val totalStudents: Long,
    val totalFaculty: Long,
    val totalOrganizations: Long,
    val totalNotices: Long = 0,
    val suspendedUsers: Long
)

data class AdminAuditLogResponse(
    val id: String,
    val action: String,
    val performedBy: String,
    val target: String,
    val timestamp: Instant,
    val category: String = "user",
    val reason: String? = null,
    val targetId: String? = null
)
