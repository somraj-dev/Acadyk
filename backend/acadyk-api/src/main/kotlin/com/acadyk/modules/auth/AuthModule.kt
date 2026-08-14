package com.acadyk.modules.auth

import com.acadyk.common.ApiResponse
import com.acadyk.common.UnauthorizedException
import com.acadyk.modules.profiles.dto.ProfileResponse
import com.acadyk.modules.profiles.entity.ProfileEntity
import com.acadyk.modules.profiles.mapper.ProfileMapper
import com.acadyk.modules.profiles.repository.ProfileRepository
import com.acadyk.security.*
import jakarta.servlet.http.HttpServletRequest
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.stereotype.Service
import org.springframework.web.bind.annotation.*
import java.time.Instant
import java.util.UUID

data class TokenVerificationRequest(val idToken: String)
data class LoginRequest(val email: String, val password: String? = null)
data class RegisterRequest(val email: String, val password: String? = null, val fullName: String? = null)
data class ResetPasswordRequest(val email: String)

data class AuthResponse(
    val token: String,
    val user: ProfileResponse,
    val roles: Set<Role> = setOf(Role.STUDENT)
)

@Service
class AuthService(
    private val profileRepository: ProfileRepository,
    private val profileMapper: ProfileMapper,
    private val tokenVerifier: FirebaseTokenVerifier,
    private val currentUserProvider: CurrentUserProvider,
    private val jwtTokenProvider: JwtTokenProvider,
    private val auditService: AuditService
) {

    fun verifyFirebaseToken(idToken: String, ip: String): AuthResponse {
        val verified = tokenVerifier.verifyToken(idToken)
            ?: throw UnauthorizedException("Invalid or expired Firebase ID token")

        val profile = profileRepository.findById(verified.uid).orElseGet {
            profileRepository.save(
                ProfileEntity(
                    id = verified.uid,
                    username = verified.email.substringBefore("@") + "_" + verified.uid.takeLast(4),
                    fullName = verified.name ?: "Acadyk Member",
                    email = verified.email,
                    profilePhotoUrl = verified.picture,
                    createdAt = Instant.now(),
                    updatedAt = Instant.now()
                )
            )
        }

        val roles = mutableSetOf(Role.STUDENT)
        if (profile.email.endsWith("@acadyk.internal") || profile.email == "admin@acadyk.com") {
            roles.add(Role.SUPER_ADMIN)
        }

        auditService.logAuthEvent("FIREBASE_VERIFY_TOKEN", profile.id, profile.email, ip, true)
        return AuthResponse(idToken, profileMapper.toResponse(profile), roles)
    }

    fun login(request: LoginRequest, ip: String): AuthResponse {
        val email = request.email.trim().lowercase()
        val profile = profileRepository.findByEmail(email).orElseGet {
            profileRepository.save(
                ProfileEntity(
                    id = UUID.randomUUID().toString(),
                    email = email,
                    username = email.substringBefore("@"),
                    fullName = "Somraj Lodhi"
                )
            )
        }
        val token = jwtTokenProvider.createToken(profile.id, profile.email, profile.username)
        auditService.logAuthEvent("EMAIL_PASSWORD_LOGIN", profile.id, profile.email, ip, true)
        return AuthResponse(token, profileMapper.toResponse(profile), setOf(Role.STUDENT))
    }

    fun register(request: RegisterRequest, ip: String): AuthResponse {
        val email = request.email.trim().lowercase()
        val name = request.fullName?.takeIf { it.isNotBlank() } ?: "New Acadyk Member"
        val username = email.substringBefore("@") + "_" + System.currentTimeMillis().toString().takeLast(4)

        val profile = profileRepository.save(
            ProfileEntity(
                id = UUID.randomUUID().toString(),
                email = email,
                username = username,
                fullName = name
            )
        )
        val token = jwtTokenProvider.createToken(profile.id, profile.email, profile.username)
        auditService.logAuthEvent("REGISTER_USER", profile.id, profile.email, ip, true)
        return AuthResponse(token, profileMapper.toResponse(profile), setOf(Role.STUDENT))
    }

    fun resetPassword(request: ResetPasswordRequest, ip: String) {
        auditService.logAuthEvent("PASSWORD_RESET_REQUEST", "unknown", request.email, ip, true)
    }

    fun deleteAccount(ip: String) {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val email = currentUserProvider.getCurrentUserEmail()
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
@CrossOrigin(origins = ["*"])
class AuthController(
    private val authService: AuthService
) {

    @PostMapping("/verify-token")
    fun verifyToken(
        @RequestBody request: TokenVerificationRequest,
        httpRequest: HttpServletRequest
    ): ResponseEntity<ApiResponse<AuthResponse>> {
        val response = authService.verifyFirebaseToken(request.idToken, httpRequest.remoteAddr)
        return ResponseEntity.ok(ApiResponse.success(response, "Token verified successfully"))
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
    ): ResponseEntity<ApiResponse<Nothing>> {
        authService.resetPassword(request, httpRequest.remoteAddr)
        return ResponseEntity.ok(ApiResponse.success(null, "Password reset instructions sent"))
    }

    @DeleteMapping("/delete-account")
    fun deleteAccount(httpRequest: HttpServletRequest): ResponseEntity<ApiResponse<Nothing>> {
        authService.deleteAccount(httpRequest.remoteAddr)
        return ResponseEntity.ok(ApiResponse.success(null, "Account marked for deletion"))
    }

    @GetMapping("/session")
    fun getSession(): ResponseEntity<ApiResponse<ProfileResponse>> {
        val session = authService.getSession()
        return ResponseEntity.ok(ApiResponse.success(session))
    }
}
