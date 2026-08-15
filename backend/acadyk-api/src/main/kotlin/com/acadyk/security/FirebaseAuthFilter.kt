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
                    .or { userRepository.findByCollegeEmail(email) }
                    .orElseGet {
                        val parsed = enrollmentNumberService.parseCollegeEmail(email)
                        userRepository.save(
                            UserEntity(
                                id = verifiedUser.uid,
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

                val profile = profileRepository.findById(user.id).orElseGet {
                    profileRepository.save(
                        ProfileEntity(
                            id = user.id,
                            username = user.enrollmentNumber ?: email.substringBefore("@"),
                            fullName = verifiedUser.name ?: "Somraj Lodhi",
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
                val roles = mutableSetOf(user.role)
                if (profile.email.endsWith("@acadyk.internal") || profile.email == "admin@acadyk.com") {
                    roles.add(Role.SUPER_ADMIN)
                }

                val principal = UserPrincipal(
                    id = profile.id,
                    email = profile.email,
                    username = profile.username,
                    roles = roles,
                    isEmailVerified = verifiedUser.isEmailVerified
                )

                val auth = UsernamePasswordAuthenticationToken(principal, null, principal.authorities)
                SecurityContextHolder.getContext().authentication = auth
            }
        }
        filterChain.doFilter(request, response)
    }
}
