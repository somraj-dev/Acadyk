package com.acadyk.modules.admin.service

import com.acadyk.common.BadRequestException
import com.acadyk.common.ConflictException
import com.acadyk.common.ResourceNotFoundException
import com.acadyk.common.toUUID
import com.acadyk.modules.admin.dto.*
import com.acadyk.modules.clubs.repository.ClubRepository
import com.acadyk.modules.communities.repository.CommunityRepository
import com.acadyk.modules.events.repository.EventRepository
import com.acadyk.modules.posts.repository.PostRepository
import com.acadyk.modules.profiles.entity.ProfileEntity
import com.acadyk.modules.profiles.repository.ProfileRepository
import com.acadyk.modules.users.entity.AccountStatus
import com.acadyk.modules.users.entity.UserEntity
import com.acadyk.modules.users.repository.UserRepository
import com.acadyk.security.AuditService
import com.acadyk.security.Role
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.time.LocalDate
import java.time.format.DateTimeParseException
import java.util.UUID

@Service
class AdminUserService(
    private val userRepository: UserRepository,
    private val profileRepository: ProfileRepository,
    private val eventRepository: EventRepository,
    private val clubRepository: ClubRepository,
    private val postRepository: PostRepository,
    private val communityRepository: CommunityRepository,
    private val authAuditLogRepository: com.acadyk.modules.users.repository.AuthAuditLogRepository,
    private val auditService: AuditService
) {

    @Transactional(readOnly = true)
    fun getUsers(
        search: String?,
        role: Role?,
        status: String?,
        course: String?,
        branch: String?,
        department: String?,
        page: Int = 0,
        size: Int = 100
    ): List<AdminUserResponse> {
        val allUsers = userRepository.findAllByDeletedAtIsNullOrderByCreatedAtDesc()

        val filtered = allUsers.filter { user ->
            var matches = true

            if (!search.isNullOrBlank()) {
                val q = search.trim().lowercase()
                val profile = profileRepository.findByUserId(user.id).orElse(null)
                val matchesSearch = user.email.lowercase().contains(q) ||
                        (user.collegeEmail?.lowercase()?.contains(q) == true) ||
                        (user.enrollmentNumber?.lowercase()?.contains(q) == true) ||
                        (user.employeeId?.lowercase()?.contains(q) == true) ||
                        (user.department?.lowercase()?.contains(q) == true) ||
                        (user.branch?.lowercase()?.contains(q) == true) ||
                        (profile?.fullName?.lowercase()?.contains(q) == true)

                if (!matchesSearch) matches = false
            }

            if (matches && role != null) {
                if (user.role != role) matches = false
            }

            if (matches && !status.isNullOrBlank() && status.lowercase() != "all") {
                val s = status.uppercase()
                if (user.accountStatus.name != s) matches = false
            }

            if (matches && !course.isNullOrBlank()) {
                if (!user.degree.equals(course, ignoreCase = true)) matches = false
            }

            if (matches && !branch.isNullOrBlank()) {
                if (!user.branch.equals(branch, ignoreCase = true)) matches = false
            }

            if (matches && !department.isNullOrBlank()) {
                if (!user.department.equals(department, ignoreCase = true)) matches = false
            }

            matches
        }

        // Fetch profiles and map to response
        return filtered.map { user ->
            val profile = profileRepository.findByUserId(user.id).or { profileRepository.findById(user.id) }.orElse(null)
            mapToAdminUserResponse(user, profile)
        }
    }

    @Transactional(readOnly = true)
    fun getUserById(id: String): AdminUserResponse {
        val user = try {
            userRepository.findById(id.toUUID()).orElse(null)
        } catch (_: Exception) {
            null
        } ?: userRepository.findByEnrollmentNumber(id).orElse(null)
          ?: userRepository.findByEmployeeId(id).orElse(null)
          ?: userRepository.findByEmail(id.lowercase().trim()).orElse(null)
          ?: throw ResourceNotFoundException("User not found with identifier: $id")

        if (user.deletedAt != null) {
            throw ResourceNotFoundException("User has been deleted: $id")
        }

        val profile = profileRepository.findByUserId(user.id).orElse(null)
        return mapToAdminUserResponse(user, profile)
    }

    @Transactional
    fun createUser(request: CreateAdminUserRequest, adminEmail: String): AdminUserResponse {
        val fullName = request.fullName.trim()
        if (fullName.isBlank()) {
            throw BadRequestException("Full name is required.")
        }

        val email = request.email.trim().lowercase()
        if (email.isBlank() || !email.contains("@") || !email.contains(".")) {
            throw BadRequestException("A valid email address is required.")
        }

        // Check for duplicate email
        if (userRepository.existsByEmail(email) || userRepository.existsByCollegeEmail(email)) {
            throw ConflictException("A user with email '$email' already exists in the system.")
        }

        // Check for duplicate enrollment number
        val enrollment = request.enrollmentNumber?.trim()?.takeIf { it.isNotBlank() }
        if (enrollment != null && userRepository.existsByEnrollmentNumber(enrollment)) {
            throw ConflictException("A student with enrollment number '$enrollment' already exists in the system.")
        }

        // Check for duplicate employee ID
        val empId = request.employeeId?.trim()?.takeIf { it.isNotBlank() }
        if (empId != null && userRepository.existsByEmployeeId(empId)) {
            throw ConflictException("A faculty/staff member with Employee ID '$empId' already exists in the system.")
        }

        val userId = UUID.randomUUID()
        val parsedDob = parseLocalDate(request.dateOfBirth)
        val parsedAdmissionDate = parseLocalDate(request.admissionDate)
        val parsedRegDate = parseLocalDate(request.registrationDate) ?: LocalDate.now()
        val joiningYear = request.joiningYear ?: LocalDate.now().year

        val accountStatus = try {
            AccountStatus.valueOf(request.status.trim().uppercase())
        } catch (_: Exception) {
            AccountStatus.ACTIVE
        }

        val userEntity = UserEntity(
            id = userId,
            firebaseUid = "pre_provisioned_$userId",
            email = email,
            collegeEmail = email,
            enrollmentNumber = enrollment,
            employeeId = empId,
            degree = request.course?.trim() ?: "B.Tech",
            branch = request.branch?.trim(),
            department = request.department?.trim(),
            joiningYear = joiningYear,
            role = request.role,
            accountStatus = accountStatus,
            isActive = (accountStatus == AccountStatus.ACTIVE),
            isEmailVerified = false,
            profileCompleted = false,
            authProvider = "FIREBASE_GOOGLE",
            phone = request.phone?.trim(),
            fatherName = request.fatherName?.trim(),
            fatherMobile = request.fatherMobile?.trim(),
            currentAddress = request.currentAddress?.trim(),
            designation = request.designation?.trim(),
            dateOfBirth = parsedDob,
            admissionDate = parsedAdmissionDate,
            registrationDate = parsedRegDate,
            createdAt = Instant.now(),
            updatedAt = Instant.now()
        )

        val savedUser = userRepository.save(userEntity)

        val profileEntity = ProfileEntity(
            id = UUID.randomUUID(),
            userId = userId,
            username = enrollment ?: empId ?: email.substringBefore("@"),
            fullName = fullName,
            email = email,
            collegeName = "Madhav Institute of Technology & Science, Gwalior",
            major = request.branch?.trim() ?: "Engineering",
            graduationYear = joiningYear + 4,
            createdAt = Instant.now(),
            updatedAt = Instant.now()
        )

        val savedProfile = profileRepository.save(profileEntity)

        auditService.logAuthEvent(
            action = "ADMIN_CREATE_USER",
            userId = savedUser.id,
            email = savedUser.email,
            ipAddress = "127.0.0.1",
            success = true,
            details = "Created ${savedUser.role} record (Enrollment: $enrollment) by admin $adminEmail"
        )

        return mapToAdminUserResponse(savedUser, savedProfile)
    }

    @Transactional
    fun updateUser(userIdStr: String, request: UpdateAdminUserRequest, adminEmail: String): AdminUserResponse {
        val userId = userIdStr.toUUID()
        val user = userRepository.findById(userId)
            .orElseThrow { ResourceNotFoundException("User not found with ID: $userIdStr") }

        if (user.deletedAt != null) {
            throw BadRequestException("Cannot update a deleted user.")
        }

        val profile = profileRepository.findByUserId(userId).orElseGet {
            ProfileEntity(
                id = UUID.randomUUID(),
                userId = userId,
                username = user.enrollmentNumber ?: user.email.substringBefore("@"),
                fullName = user.email.substringBefore("@"),
                email = user.email
            )
        }

        request.fullName?.trim()?.takeIf { it.isNotBlank() }?.let {
            profile.fullName = it
        }

        request.email?.trim()?.lowercase()?.takeIf { it.isNotBlank() }?.let { newEmail ->
            if (newEmail != user.email) {
                val existing = userRepository.findByEmail(newEmail)
                if (existing.isPresent && existing.get().id != user.id) {
                    throw ConflictException("Email '$newEmail' is already in use by another account.")
                }
                user.email = newEmail
                user.collegeEmail = newEmail
                profile.email = newEmail
            }
        }

        request.enrollmentNumber?.trim()?.takeIf { it.isNotBlank() }?.let { newEnroll ->
            if (newEnroll != user.enrollmentNumber) {
                val existing = userRepository.findByEnrollmentNumber(newEnroll)
                if (existing.isPresent && existing.get().id != user.id) {
                    throw ConflictException("Enrollment number '$newEnroll' is already bound to another account.")
                }
                user.enrollmentNumber = newEnroll
                profile.username = newEnroll
            }
        }

        request.employeeId?.trim()?.takeIf { it.isNotBlank() }?.let { newEmpId ->
            if (newEmpId != user.employeeId) {
                val existing = userRepository.findByEmployeeId(newEmpId)
                if (existing.isPresent && existing.get().id != user.id) {
                    throw ConflictException("Employee ID '$newEmpId' is already in use.")
                }
                user.employeeId = newEmpId
            }
        }

        request.role?.let { user.role = it }
        request.department?.let { user.department = it.trim() }
        request.course?.let { user.degree = it.trim() }
        request.branch?.let { user.branch = it.trim(); profile.major = it.trim() }
        request.joiningYear?.let { user.joiningYear = it; profile.graduationYear = it + 4 }
        request.phone?.let { user.phone = it.trim() }
        request.fatherName?.let { user.fatherName = it.trim() }
        request.fatherMobile?.let { user.fatherMobile = it.trim() }
        request.currentAddress?.let { user.currentAddress = it.trim() }
        request.designation?.let { user.designation = it.trim() }

        request.dateOfBirth?.let { user.dateOfBirth = parseLocalDate(it) }
        request.admissionDate?.let { user.admissionDate = parseLocalDate(it) }
        request.registrationDate?.let { user.registrationDate = parseLocalDate(it) }

        request.status?.trim()?.uppercase()?.let { newStatusStr ->
            try {
                val newStatus = AccountStatus.valueOf(newStatusStr)
                user.accountStatus = newStatus
                user.isActive = (newStatus == AccountStatus.ACTIVE)
            } catch (_: Exception) {}
        }

        user.updatedAt = Instant.now()
        profile.updatedAt = Instant.now()

        val savedUser = userRepository.save(user)
        val savedProfile = profileRepository.save(profile)

        auditService.logAuthEvent(
            action = "ADMIN_UPDATE_USER",
            userId = savedUser.id,
            email = savedUser.email,
            ipAddress = "127.0.0.1",
            success = true,
            details = "Updated user profile details by admin $adminEmail"
        )

        return mapToAdminUserResponse(savedUser, savedProfile)
    }

    @Transactional
    fun updateUserStatus(userIdStr: String, request: UpdateUserStatusRequest, adminEmail: String): AdminUserResponse {
        val userId = userIdStr.toUUID()
        val user = userRepository.findById(userId)
            .orElseThrow { ResourceNotFoundException("User not found: $userIdStr") }

        val newStatus = try {
            AccountStatus.valueOf(request.status.trim().uppercase())
        } catch (_: Exception) {
            throw BadRequestException("Invalid status value: ${request.status}")
        }

        user.accountStatus = newStatus
        user.isActive = (newStatus == AccountStatus.ACTIVE)

        if (newStatus == AccountStatus.SUSPENDED) {
            user.suspensionReason = request.reason ?: "Suspended by Administrator"
            user.suspendedAt = Instant.now()
            user.suspendedBy = adminEmail
        } else if (newStatus == AccountStatus.ACTIVE) {
            user.suspensionReason = null
            user.suspendedAt = null
            user.suspendedBy = null
        }

        user.updatedAt = Instant.now()
        val savedUser = userRepository.save(user)
        val profile = profileRepository.findByUserId(userId).or { profileRepository.findById(userId) }.orElse(null)

        auditService.logAuthEvent(
            action = "ADMIN_STATUS_CHANGE",
            userId = savedUser.id,
            email = savedUser.email,
            ipAddress = "127.0.0.1",
            success = true,
            details = "Account status set to $newStatus by admin $adminEmail. Reason: ${request.reason ?: "None"}"
        )

        return mapToAdminUserResponse(savedUser, profile)
    }

    @Transactional
    fun suspendUser(userIdStr: String, reason: String?, adminEmail: String): AdminUserResponse {
        return updateUserStatus(userIdStr, UpdateUserStatusRequest(status = "SUSPENDED", reason = reason), adminEmail)
    }

    @Transactional
    fun restoreUser(userIdStr: String, adminEmail: String): AdminUserResponse {
        return updateUserStatus(userIdStr, UpdateUserStatusRequest(status = "ACTIVE"), adminEmail)
    }

    @Transactional
    fun deleteUser(userIdStr: String, adminEmail: String) {
        val userId = userIdStr.toUUID()
        val user = userRepository.findById(userId)
            .orElseThrow { ResourceNotFoundException("User not found: $userIdStr") }

        user.deletedAt = Instant.now()
        user.isActive = false
        user.accountStatus = AccountStatus.INACTIVE
        userRepository.save(user)

        profileRepository.findByUserId(userId).or { profileRepository.findById(userId) }.ifPresent {
            it.deletedAt = Instant.now()
            profileRepository.save(it)
        }

        auditService.logAuthEvent(
            action = "ADMIN_DELETE_USER",
            userId = user.id,
            email = user.email,
            ipAddress = "127.0.0.1",
            success = true,
            details = "Soft-deleted user account by admin $adminEmail"
        )
    }

    @Transactional(readOnly = true)
    fun getDashboardStats(): AdminDashboardStatsResponse {
        val totalUsers = userRepository.countByDeletedAtIsNull()
        val activeUsers = userRepository.countByAccountStatusAndDeletedAtIsNull(AccountStatus.ACTIVE)
        val suspendedUsers = userRepository.countByAccountStatusAndDeletedAtIsNull(AccountStatus.SUSPENDED)
        val totalStudents = userRepository.countByRoleAndDeletedAtIsNull(Role.STUDENT)
        val totalFaculty = userRepository.countByRoleAndDeletedAtIsNull(Role.FACULTY)

        val oneDayAgo = Instant.now().minusSeconds(86400)
        val newUsersToday = userRepository.countByCreatedAtAfterAndDeletedAtIsNull(oneDayAgo)

        val totalEvents = eventRepository.count()
        val totalClubs = clubRepository.count()
        val totalCommunities = communityRepository.count()
        val totalPosts = postRepository.count()

        return AdminDashboardStatsResponse(
            totalUsers = totalUsers,
            activeUsers = activeUsers,
            totalPosts = totalPosts,
            totalOpportunities = 0,
            totalClubs = totalClubs,
            totalEvents = totalEvents,
            pendingReports = 0,
            newUsersToday = newUsersToday,
            totalStudents = totalStudents,
            totalFaculty = totalFaculty,
            totalOrganizations = totalClubs + totalCommunities,
            totalNotices = 0,
            suspendedUsers = suspendedUsers
        )
    }

    @Transactional(readOnly = true)
    fun getAuditLogs(): List<AdminAuditLogResponse> {
        val logs = authAuditLogRepository.findAllByOrderByCreatedAtDesc().take(100)
        return logs.map { log ->
            AdminAuditLogResponse(
                id = log.id.toString(),
                action = log.eventType,
                performedBy = log.email,
                target = log.failureReason ?: log.email,
                timestamp = log.createdAt,
                category = "user",
                reason = log.failureReason,
                targetId = log.userId?.toString()
            )
        }
    }

    private fun mapToAdminUserResponse(user: UserEntity, profile: ProfileEntity?): AdminUserResponse {
        val currentYear = LocalDate.now().year
        val joiningYear = user.joiningYear ?: (user.createdAt.atZone(java.time.ZoneOffset.UTC).year)
        val academicYear = (currentYear - joiningYear + 1).coerceIn(1, 4)
        val semester = academicYear * 2
        val batch = "$joiningYear-${joiningYear + 4}"

        return AdminUserResponse(
            id = user.id.toString(),
            fullName = profile?.fullName ?: user.email.substringBefore("@"),
            email = user.email,
            role = user.role.name,
            status = user.accountStatus.name.lowercase(),
            department = user.department,
            avatarUrl = profile?.profilePhotoUrl,
            enrollmentNumber = user.enrollmentNumber,
            employeeId = user.employeeId,
            course = user.degree,
            branch = user.branch ?: profile?.major,
            joiningYear = user.joiningYear,
            year = academicYear,
            semester = semester,
            batch = batch,
            phone = user.phone,
            designation = user.designation,
            fatherName = user.fatherName,
            fatherMobile = user.fatherMobile,
            currentAddress = user.currentAddress,
            dateOfBirth = user.dateOfBirth?.toString(),
            admissionDate = user.admissionDate?.toString(),
            registrationDate = user.registrationDate?.toString() ?: user.createdAt.toString(),
            joinedAt = user.createdAt,
            lastActive = user.lastLoginAt ?: user.lastSignInAt ?: user.createdAt,
            postsCount = 0,
            suspensionReason = user.suspensionReason,
            suspendedAt = user.suspendedAt,
            suspendedBy = user.suspendedBy
        )
    }

    private fun parseLocalDate(str: String?): LocalDate? {
        if (str.isNullOrBlank()) return null
        return try {
            LocalDate.parse(str.substringBefore("T"))
        } catch (_: DateTimeParseException) {
            null
        }
    }
}
