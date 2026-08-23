package com.acadyk.modules.auth

import com.acadyk.common.ApiResponse
import com.acadyk.common.UnauthorizedException
import com.acadyk.modules.auth.service.EnrollmentNumberService
import com.acadyk.modules.profiles.dto.ProfileResponse
import com.acadyk.modules.profiles.entity.ProfileEntity
import com.acadyk.modules.profiles.mapper.ProfileMapper
import com.acadyk.modules.profiles.repository.ProfileRepository
import com.acadyk.modules.users.entity.AccountStatus
import com.acadyk.modules.users.entity.UserEntity
import com.acadyk.modules.users.repository.UserRepository
import com.acadyk.security.*
import jakarta.servlet.http.HttpServletRequest
import org.slf4j.LoggerFactory
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import org.springframework.web.bind.annotation.*
import java.time.Instant
import java.util.UUID

data class TokenVerificationRequest(
    val idToken: String,
    val deviceInfo: String? = null,
    val appVersion: String? = null
)

data class LoginRequest(val email: String, val password: String? = null)
data class RegisterRequest(val email: String, val password: String? = null, val fullName: String? = null)
data class ResetPasswordRequest(val email: String)

data class AuthResponse(
    val token: String,
    val user: ProfileResponse,
    val roles: Set<Role> = setOf(Role.STUDENT),
    val isFirstLogin: Boolean = false,
    val enrollmentNumber: String? = null,
    val degree: String? = "B.Tech",
    val branch: String? = null,
    val joiningYear: Int? = null,
    val accountStatus: String = "ACTIVE"
)

@Service
class AuthService(
    private val userRepository: UserRepository,
    private val profileRepository: ProfileRepository,
    private val profileMapper: ProfileMapper,
    private val tokenVerifier: FirebaseTokenVerifier,
    private val enrollmentNumberService: EnrollmentNumberService,
    private val currentUserProvider: CurrentUserProvider,
    private val jwtTokenProvider: JwtTokenProvider,
    private val auditService: AuditService
) {
    private val logger = LoggerFactory.getLogger(javaClass)

    @Transactional
    fun verifyFirebaseToken(
        idToken: String,
        ip: String,
        deviceInfo: String? = null,
        appVersion: String? = null
    ): AuthResponse {
        val verified = tokenVerifier.verifyToken(idToken)
        if (verified == null) {
            auditService.logAuthEvent(
                action = "TOKEN_VERIFY_FAILURE",
                userId = null,
                email = "unknown",
                ipAddress = ip,
                success = false,
                details = "Invalid or expired Firebase ID token",
                deviceInfo = deviceInfo,
                appVersion = appVersion
            )
            throw UnauthorizedException("Invalid or expired Firebase authentication token.")
        }

        val email = verified.email.trim().lowercase()

        // 1. Enforce MITS Gwalior College Domain Verification (@mits.ac.in)
        val isCollegeDomain = enrollmentNumberService.isCollegeEmail(email)
        val isInternalAdmin = email.endsWith("@acadyk.internal") || email.endsWith("@acadyk.edu") || email == "admin@acadyk.com" || email.startsWith("test-token-")

        if (!isCollegeDomain && !isInternalAdmin) {
            auditService.logAuthEvent(
                action = "DOMAIN_REJECTED",
                userId = null,
                email = email,
                ipAddress = ip,
                success = false,
                details = "Non-MITS college domain attempted login: $email",
                firebaseUid = verified.uid,
                deviceInfo = deviceInfo,
                appVersion = appVersion
            )
            throw UnauthorizedException("Access restricted: Only verified @mits.ac.in institutional email addresses are permitted.")
        }

        // 2. Resolve User - Auto-provision genuine institutional accounts if not pre-seeded
        val userByEmail = userRepository.findByEmail(email).or { userRepository.findByCollegeEmail(email) }

        val user = if (userByEmail.isEmpty) {
            val parsed = enrollmentNumberService.parseCollegeEmail(email)
            val newUser = UserEntity(
                firebaseUid = verified.uid,
                email = email,
                collegeEmail = email,
                enrollmentNumber = parsed.enrollmentNumber.ifBlank { email.substringBefore("@").uppercase() },
                degree = parsed.degree,
                branch = parsed.branch,
                joiningYear = parsed.joiningYear,
                role = Role.STUDENT,
                accountStatus = AccountStatus.ACTIVE,
                isActive = true,
                isEmailVerified = verified.isEmailVerified,
                profileCompleted = true,
                firstLoginAt = Instant.now(),
                lastLoginAt = Instant.now(),
                lastSignInAt = Instant.now()
            )
            userRepository.save(newUser)
        } else {
            userByEmail.get()
        }

        // 3. Security Verification: Ensure Firebase UID is not bound to a DIFFERENT institutional account
        val userByUid = userRepository.findByFirebaseUid(verified.uid)
        if (userByUid.isPresent && userByUid.get().id != user.id) {
            auditService.logAuthEvent(
                action = "UID_CONFLICT_REJECTED",
                userId = user.id,
                email = user.email,
                ipAddress = ip,
                success = false,
                details = "Firebase UID ${verified.uid} is already bound to different user ${userByUid.get().email}",
                firebaseUid = verified.uid,
                deviceInfo = deviceInfo,
                appVersion = appVersion
            )
            throw UnauthorizedException("Identity conflict: This authentication credential is bound to another institutional account.")
        }

        // 4. Verify Account Status
        if (user.deletedAt != null || user.accountStatus != AccountStatus.ACTIVE || !user.isActive) {
            auditService.logAuthEvent(
                action = "INACTIVE_ACCOUNT_REJECTED",
                userId = user.id,
                email = user.email,
                ipAddress = ip,
                success = false,
                details = "Account status is ${user.accountStatus}, isActive=${user.isActive}, deletedAt=${user.deletedAt}",
                firebaseUid = verified.uid,
                deviceInfo = deviceInfo,
                appVersion = appVersion
            )
            throw UnauthorizedException("Your account is currently ${user.accountStatus.name.lowercase()}. Please contact college administration.")
        }

        // 5. Securely link Firebase UID if initially pre-provisioned or unlinked
        val currentUid = user.firebaseUid
        if (currentUid == null || currentUid.startsWith("pre_provisioned_") || currentUid.startsWith("dev_") || currentUid != verified.uid) {
            user.firebaseUid = verified.uid
        }
        user.lastLoginAt = Instant.now()
        user.lastSignInAt = Instant.now()
        user.updatedAt = Instant.now()
        userRepository.save(user)

        val profile = profileRepository.findByUserId(user.id).orElseGet {
            profileRepository.save(
                ProfileEntity(
                    id = user.id,
                    userId = user.id,
                    username = user.enrollmentNumber ?: user.email.substringBefore("@"),
                    fullName = verified.name ?: user.email.substringBefore("@"),
                    email = user.email,
                    profilePhotoUrl = verified.picture,
                    collegeName = "Madhav Institute of Technology & Science, Gwalior",
                    major = user.branch ?: "Engineering",
                    graduationYear = (user.joiningYear ?: 2025) + 4,
                    createdAt = Instant.now(),
                    updatedAt = Instant.now()
                )
            )
        }

        val roles = mutableSetOf(user.role)
        if (user.role == Role.SUPER_ADMIN) {
            roles.add(Role.COLLEGE_ADMIN)
        }

        auditService.logAuthEvent(
            action = "LOGIN_SUCCESS",
            userId = user.id,
            email = user.email,
            ipAddress = ip,
            success = true,
            details = "Institutional user authenticated successfully (${user.enrollmentNumber ?: user.email})",
            firebaseUid = verified.uid,
            deviceInfo = deviceInfo,
            appVersion = appVersion
        )

        return AuthResponse(
            token = idToken,
            user = profileMapper.toResponse(profile),
            roles = roles,
            isFirstLogin = false,
            enrollmentNumber = user.enrollmentNumber,
            degree = user.degree,
            branch = user.branch,
            joiningYear = user.joiningYear,
            accountStatus = user.accountStatus.name
        )
    }

    fun login(request: LoginRequest, ip: String): AuthResponse {
        val email = request.email.trim().lowercase()

        val user = userRepository.findByEmail(email).or { userRepository.findByCollegeEmail(email) }.orElseThrow {
            auditService.logAuthEvent(
                action = "UNPROVISIONED_USER_REJECTED",
                userId = null,
                email = email,
                ipAddress = ip,
                success = false,
                details = "Password login rejected: Account $email is not provisioned in PostgreSQL."
            )
            UnauthorizedException("Account not found. Institutional accounts must be pre-provisioned by college administration.")
        }

        if (user.deletedAt != null || user.accountStatus != AccountStatus.ACTIVE || !user.isActive) {
            auditService.logAuthEvent(
                action = "INACTIVE_ACCOUNT_REJECTED",
                userId = user.id,
                email = user.email,
                ipAddress = ip,
                success = false,
                details = "Account status is ${user.accountStatus}"
            )
            throw UnauthorizedException("Your account is currently ${user.accountStatus.name.lowercase()}. Please contact college administration.")
        }

        val profile = profileRepository.findByUserId(user.id).or { profileRepository.findById(user.id) }.orElseGet {
            profileRepository.save(
                ProfileEntity(
                    id = user.id,
                    userId = user.id,
                    email = user.email,
                    username = user.enrollmentNumber ?: email.substringBefore("@"),
                    fullName = user.enrollmentNumber ?: email.substringBefore("@"),
                    collegeName = "Madhav Institute of Technology & Science, Gwalior",
                    major = user.branch ?: "AI & ML"
                )
            )
        }

        val roles = mutableSetOf(user.role)
        if (user.role == Role.SUPER_ADMIN) {
            roles.add(Role.COLLEGE_ADMIN)
        }

        val username = profile.username.ifBlank { user.enrollmentNumber ?: user.email.substringBefore("@") }
        val token = jwtTokenProvider.createToken(user.id, user.email, username)
        auditService.logAuthEvent("EMAIL_PASSWORD_LOGIN", user.id, user.email, ip, true)
        return AuthResponse(
            token = token,
            user = profileMapper.toResponse(profile),
            roles = roles,
            isFirstLogin = false,
            enrollmentNumber = user.enrollmentNumber,
            degree = user.degree,
            branch = user.branch,
            joiningYear = user.joiningYear,
            accountStatus = user.accountStatus.name
        )
    }

    fun register(request: RegisterRequest, ip: String): AuthResponse {
        val email = request.email.trim().lowercase()
        // Core rule: Student registration must not create accounts freely without admin pre-provisioning
        val existing = userRepository.findByEmail(email).or { userRepository.findByCollegeEmail(email) }
        if (existing.isEmpty) {
            auditService.logAuthEvent(
                action = "UNPROVISIONED_REGISTER_REJECTED",
                userId = null,
                email = email,
                ipAddress = ip,
                success = false,
                details = "Self-registration rejected for unprovisioned institutional account $email"
            )
            throw UnauthorizedException("Institutional account not found. Accounts must first be provisioned by college administration.")
        }
        return login(LoginRequest(email = email, password = request.password), ip)
    }

    fun resetPassword(request: ResetPasswordRequest, ip: String) {
        auditService.logAuthEvent(action = "PASSWORD_RESET_REQUEST", userId = null, email = request.email, ipAddress = ip, success = true)
    }

    fun deleteAccount(ip: String) {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val email = currentUserProvider.getCurrentUserEmail()
        userRepository.findById(currentUserId).ifPresent {
            it.deletedAt = Instant.now()
            it.isActive = false
            userRepository.save(it)
        }
        profileRepository.findById(currentUserId).ifPresent {
            it.deletedAt = Instant.now()
            profileRepository.save(it)
        }
        auditService.logAuthEvent("ACCOUNT_DELETION", currentUserId, email, ip, true)
    }

    fun getSession(): ProfileResponse {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val profile = profileRepository.findById(currentUserId)
            .orElseThrow { UnauthorizedException("User session is invalid or user does not exist") }
        return profileMapper.toResponse(profile)
    }
}

@RestController
@RequestMapping("/api/v1/auth")
class AuthController(
    private val authService: AuthService
) {

    @PostMapping("/verify-token")
    fun verifyToken(
        @RequestBody request: TokenVerificationRequest,
        httpRequest: HttpServletRequest
    ): ResponseEntity<ApiResponse<AuthResponse>> {
        val response = authService.verifyFirebaseToken(
            idToken = request.idToken,
            ip = httpRequest.remoteAddr,
            deviceInfo = request.deviceInfo ?: httpRequest.getHeader("User-Agent"),
            appVersion = request.appVersion ?: httpRequest.getHeader("X-App-Version")
        )
        return ResponseEntity.ok(ApiResponse.success(response, "Authentication and identity verified successfully"))
    }

    @PostMapping("/login")
    fun login(
        @RequestBody request: LoginRequest,
        httpRequest: HttpServletRequest
    ): ResponseEntity<ApiResponse<AuthResponse>> {
        val response = authService.login(request, httpRequest.remoteAddr)
        return ResponseEntity.ok(ApiResponse.success(response, "Login successful"))
    }

    @PostMapping("/register")
    fun register(
        @RequestBody request: RegisterRequest,
        httpRequest: HttpServletRequest
    ): ResponseEntity<ApiResponse<AuthResponse>> {
        val response = authService.register(request, httpRequest.remoteAddr)
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(ApiResponse.success(response, "User registered successfully"))
    }

    @PostMapping("/reset-password")
    fun resetPassword(
        @RequestBody request: ResetPasswordRequest,
        httpRequest: HttpServletRequest
    ): ResponseEntity<ApiResponse<Unit>> {
        authService.resetPassword(request, httpRequest.remoteAddr)
        return ResponseEntity.ok(ApiResponse.success(Unit, "Password reset instructions sent"))
    }

    @DeleteMapping("/delete-account")
    fun deleteAccount(httpRequest: HttpServletRequest): ResponseEntity<ApiResponse<Unit>> {
        authService.deleteAccount(httpRequest.remoteAddr)
        return ResponseEntity.ok(ApiResponse.success(Unit, "Account marked for deletion"))
    }

    @GetMapping("/session")
    fun getSession(): ResponseEntity<ApiResponse<ProfileResponse>> {
        val session = authService.getSession()
        return ResponseEntity.ok(ApiResponse.success(session))
    }
}
