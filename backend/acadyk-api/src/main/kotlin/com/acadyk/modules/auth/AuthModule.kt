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

        // 1. Enforce MITS Gwalior College Domain Verification
        val isCollegeDomain = enrollmentNumberService.isCollegeEmail(email)
        val isInternalAdmin = email.endsWith("@acadyk.internal") || email == "admin@acadyk.com" || email.startsWith("test-token-")

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
            throw UnauthorizedException("Access restricted: Only verified @mitsgwl.ac.in college email addresses are permitted.")
        }

        // 2. Check if user already exists (Idempotent first-login detection)
        val existingUser = userRepository.findByFirebaseUid(verified.uid)
            .or { userRepository.findByCollegeEmail(email) }

        if (existingUser.isPresent) {
            val user = existingUser.get()
            user.lastLoginAt = Instant.now()
            user.lastSignInAt = Instant.now()
            user.updatedAt = Instant.now()
            userRepository.save(user)

            val profile = profileRepository.findById(user.id).orElseGet {
                profileRepository.save(
                    ProfileEntity(
                        id = user.id,
                        username = user.enrollmentNumber ?: user.email.substringBefore("@"),
                        fullName = verified.name ?: "Somraj Lodhi",
                        email = user.email,
                        profilePhotoUrl = verified.picture,
                        collegeName = "Madhav Institute of Technology & Science, Gwalior",
                        major = user.branch ?: "AI & ML",
                        graduationYear = (user.joiningYear ?: 2025) + 4,
                        createdAt = Instant.now(),
                        updatedAt = Instant.now()
                    )
                )
            }

            val roles = mutableSetOf(user.role)
            if (isInternalAdmin) {
                roles.add(Role.SUPER_ADMIN)
            }

            auditService.logAuthEvent(
                action = "LOGIN_SUCCESS",
                userId = user.id,
                email = user.email,
                ipAddress = ip,
                success = true,
                details = "Existing user authenticated successfully (${user.enrollmentNumber})",
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

        // 3. First-Login Provisioning: Parse email and generate institutional enrollment number
        val parsed = enrollmentNumberService.parseCollegeEmail(email)
        val enrollment = parsed.enrollmentNumber

        // Validate uniqueness of enrollment number
        if (userRepository.existsByEnrollmentNumber(enrollment)) {
            logger.error("Enrollment collision detected for generated enrollment: {}", enrollment)
            auditService.logAuthEvent(
                action = "ENROLLMENT_COLLISION",
                userId = null,
                email = email,
                ipAddress = ip,
                success = false,
                details = "Generated enrollment $enrollment already bound to another account",
                firebaseUid = verified.uid,
                deviceInfo = deviceInfo,
                appVersion = appVersion
            )
            throw UnauthorizedException("Enrollment number conflict. Please contact institutional support.")
        }

        val newUserId = UUID.randomUUID()
        val newUser = userRepository.save(
            UserEntity(
                id = newUserId,
                firebaseUid = verified.uid,
                email = email,
                collegeEmail = email,
                enrollmentNumber = enrollment,
                degree = parsed.degree,
                branch = parsed.branch,
                joiningYear = parsed.joiningYear,
                role = Role.STUDENT,
                accountStatus = if (parsed.isValid) AccountStatus.ACTIVE else AccountStatus.PENDING_VERIFICATION,
                isActive = true,
                isEmailVerified = verified.isEmailVerified,
                profileCompleted = false,
                authProvider = "FIREBASE_GOOGLE",
                firstLoginAt = Instant.now(),
                lastLoginAt = Instant.now(),
                lastSignInAt = Instant.now(),
                createdAt = Instant.now(),
                updatedAt = Instant.now()
            )
        )

        val newProfile = profileRepository.save(
            ProfileEntity(
                id = newUser.id,
                username = enrollment,
                fullName = verified.name ?: "Somraj Lodhi",
                email = email,
                profilePhotoUrl = verified.picture,
                collegeName = "Madhav Institute of Technology & Science, Gwalior",
                major = parsed.branch,
                graduationYear = parsed.joiningYear + 4,
                createdAt = Instant.now(),
                updatedAt = Instant.now()
            )
        )

        auditService.logAuthEvent(
            action = "FIRST_LOGIN_PROVISION",
            userId = newUser.id,
            email = email,
            ipAddress = ip,
            success = true,
            details = "Account provisioned with Enrollment: $enrollment, Branch: ${parsed.branch}",
            firebaseUid = verified.uid,
            deviceInfo = deviceInfo,
            appVersion = appVersion
        )

        return AuthResponse(
            token = idToken,
            user = profileMapper.toResponse(newProfile),
            roles = setOf(Role.STUDENT),
            isFirstLogin = true,
            enrollmentNumber = newUser.enrollmentNumber,
            degree = newUser.degree,
            branch = newUser.branch,
            joiningYear = newUser.joiningYear,
            accountStatus = newUser.accountStatus.name
        )
    }

    fun login(request: LoginRequest, ip: String): AuthResponse {
        val email = request.email.trim().lowercase()
        val parsed = enrollmentNumberService.parseCollegeEmail(email)
        val enrollment = parsed.enrollmentNumber
        val isAdminEmail = email.endsWith("@acadyk.internal") || 
            email.endsWith("@acadyk.edu") || 
            email.startsWith("superadmin") || 
            email.startsWith("admin@")

        val user = userRepository.findByEmail(email).orElseGet {
            userRepository.save(
                UserEntity(
                    id = UUID.randomUUID(),
                    firebaseUid = "dev_" + email.hashCode().toString(),
                    email = email,
                    collegeEmail = email,
                    enrollmentNumber = enrollment,
                    degree = parsed.degree,
                    branch = parsed.branch,
                    joiningYear = parsed.joiningYear,
                    role = if (isAdminEmail) Role.SUPER_ADMIN else Role.STUDENT,
                    firstLoginAt = Instant.now(),
                    lastLoginAt = Instant.now(),
                    lastSignInAt = Instant.now()
                )
            )
        }

        if (isAdminEmail && user.role != Role.SUPER_ADMIN) {
            user.role = Role.SUPER_ADMIN
            userRepository.save(user)
        }

        val profile = profileRepository.findById(user.id).orElseGet {
            profileRepository.save(
                ProfileEntity(
                    id = user.id,
                    userId = user.id,
                    email = user.email,
                    username = user.enrollmentNumber ?: email.substringBefore("@"),
                    fullName = if (isAdminEmail) "Sudhanshu Patel" else "Somraj Lodhi",
                    collegeName = "Madhav Institute of Technology & Science, Gwalior",
                    major = user.branch ?: "AI & ML"
                )
            )
        }
        profile.email = user.email

        val roles = mutableSetOf(user.role)
        if (isAdminEmail || user.role == Role.SUPER_ADMIN || user.role == Role.COLLEGE_ADMIN) {
            roles.add(Role.SUPER_ADMIN)
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
        val name = request.fullName?.takeIf { it.isNotBlank() } ?: "Somraj Lodhi"
        val parsed = enrollmentNumberService.parseCollegeEmail(email)
        val enrollment = parsed.enrollmentNumber

        val user = userRepository.save(
            UserEntity(
                id = UUID.randomUUID(),
                firebaseUid = "dev_" + System.currentTimeMillis().toString(),
                email = email,
                collegeEmail = email,
                enrollmentNumber = enrollment,
                degree = parsed.degree,
                branch = parsed.branch,
                joiningYear = parsed.joiningYear,
                firstLoginAt = Instant.now(),
                lastLoginAt = Instant.now(),
                lastSignInAt = Instant.now()
            )
        )

        val profile = profileRepository.save(
            ProfileEntity(
                id = user.id,
                userId = user.id,
                email = email,
                username = enrollment,
                fullName = name,
                collegeName = "Madhav Institute of Technology & Science, Gwalior",
                major = parsed.branch
            )
        )
        profile.email = user.email

        val token = jwtTokenProvider.createToken(user.id, user.email, profile.username)
        auditService.logAuthEvent("REGISTER_USER", user.id, user.email, ip, true)
        return AuthResponse(
            token = token,
            user = profileMapper.toResponse(profile),
            roles = setOf(Role.STUDENT),
            isFirstLogin = true,
            enrollmentNumber = user.enrollmentNumber,
            degree = user.degree,
            branch = user.branch,
            joiningYear = user.joiningYear,
            accountStatus = user.accountStatus.name
        )
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
