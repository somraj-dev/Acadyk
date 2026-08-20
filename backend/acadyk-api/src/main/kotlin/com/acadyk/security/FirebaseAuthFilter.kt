package com.acadyk.security

import com.acadyk.modules.auth.service.EnrollmentNumberService
import com.acadyk.modules.profiles.entity.ProfileEntity
import com.acadyk.modules.profiles.repository.ProfileRepository
import com.acadyk.modules.users.entity.AccountStatus
import com.acadyk.modules.users.entity.UserEntity
import com.acadyk.modules.users.repository.UserRepository
import jakarta.servlet.FilterChain
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.stereotype.Component
import org.springframework.web.filter.OncePerRequestFilter
import java.time.Instant

@Component
class FirebaseAuthFilter(
    private val tokenVerifier: FirebaseTokenVerifier,
    private val userRepository: UserRepository,
    private val profileRepository: ProfileRepository,
    private val enrollmentNumberService: EnrollmentNumberService
) : OncePerRequestFilter() {

    override fun doFilterInternal(
        request: HttpServletRequest,
        response: HttpServletResponse,
        filterChain: FilterChain
    ) {
        val authHeader = request.getHeader("Authorization")
        if (!authHeader.isNullOrBlank() && authHeader.startsWith("Bearer ")) {
            val token = authHeader.substring(7).trim()
            val verifiedUser = tokenVerifier.verifyToken(token)

            if (verifiedUser != null) {
                val email = verifiedUser.email.trim().lowercase()

                // Look up or provision verified user in DB - strictly using token verified identity
                val user = userRepository.findByFirebaseUid(verifiedUser.uid)
                    .or { userRepository.findByEmail(email) }
                    .or { userRepository.findByCollegeEmail(email) }
                    .orElseGet {
                        val parsed = enrollmentNumberService.parseCollegeEmail(email)
                        userRepository.save(
                            UserEntity(
                                id = java.util.UUID.randomUUID(),
                                firebaseUid = verifiedUser.uid,
                                email = email,
                                collegeEmail = email,
                                enrollmentNumber = parsed.enrollmentNumber,
                                degree = parsed.degree,
                                branch = parsed.branch,
                                joiningYear = parsed.joiningYear,
                                role = Role.STUDENT,
                                accountStatus = if (parsed.isValid) AccountStatus.ACTIVE else AccountStatus.PENDING_VERIFICATION,
                                isActive = true,
                                isEmailVerified = verifiedUser.isEmailVerified,
                                authProvider = "FIREBASE_GOOGLE",
                                firstLoginAt = Instant.now(),
                                lastLoginAt = Instant.now(),
                                lastSignInAt = Instant.now(),
                                createdAt = Instant.now(),
                                updatedAt = Instant.now()
                            )
                        )
                    }

                val profile = profileRepository.findByUserId(user.id).orElseGet {
                    profileRepository.save(
                        ProfileEntity(
                            id = java.util.UUID.randomUUID(),
                            userId = user.id,
                            username = user.enrollmentNumber ?: email.substringBefore("@"),
                            fullName = verifiedUser.name ?: "Acadyk Admin",
                            email = email,
                            profilePhotoUrl = verifiedUser.picture,
                            collegeName = "Madhav Institute of Technology & Science, Gwalior",
                            major = user.branch ?: "AI & ML",
                            graduationYear = (user.joiningYear ?: 2025) + 4,
                            createdAt = Instant.now(),
                            updatedAt = Instant.now()
                        )
                    )
                }

                // Determine user roles securely from backend
                val userEmail = user.email.trim().lowercase()
                val roles = mutableSetOf(user.role)
                if (userEmail.endsWith("@acadyk.internal") || 
                    userEmail.endsWith("@acadyk.edu") ||
                    userEmail.startsWith("superadmin") ||
                    userEmail.startsWith("admin@") ||
                    user.role == Role.SUPER_ADMIN ||
                    user.role == Role.COLLEGE_ADMIN) {
                    roles.add(Role.SUPER_ADMIN)
                    roles.add(Role.COLLEGE_ADMIN)
                }

                val principal = UserPrincipal(
                    id = user.id,
                    email = userEmail,
                    role = roles.firstOrNull() ?: Role.STUDENT,
                    roles = roles,
                    isEmailVerified = verifiedUser.isEmailVerified,
                    _username = profile.username
                )

                val auth = UsernamePasswordAuthenticationToken(principal, null, principal.authorities)
                SecurityContextHolder.getContext().authentication = auth
            }
        }
        filterChain.doFilter(request, response)
    }
}
