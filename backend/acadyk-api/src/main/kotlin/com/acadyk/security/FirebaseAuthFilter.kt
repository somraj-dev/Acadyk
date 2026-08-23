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

                // Look up verified user in DB - strictly requiring pre-provisioning
                val user = userRepository.findByFirebaseUid(verifiedUser.uid)
                    .or { userRepository.findByEmail(email) }
                    .or { userRepository.findByCollegeEmail(email) }
                    .orElse(null)

                if (user != null && user.deletedAt == null && user.isActive && user.accountStatus == AccountStatus.ACTIVE) {
                    val curUid = user.firebaseUid
                    if (curUid != verifiedUser.uid) {
                        val existingWithUid = userRepository.findByFirebaseUid(verifiedUser.uid)
                        if (existingWithUid.isEmpty || existingWithUid.get().id == user.id) {
                            user.firebaseUid = verifiedUser.uid
                            userRepository.save(user)
                        }
                    }

                    val profile = profileRepository.findByUserId(user.id).orElse(null)

                    // Determine user roles securely from backend (derive STRICTLY from database user.role)
                    val userEmail = user.email.trim().lowercase()
                    val roles = mutableSetOf(user.role)
                    if (user.role == Role.SUPER_ADMIN) {
                        roles.add(Role.COLLEGE_ADMIN)
                    }

                    val principal = UserPrincipal(
                        id = user.id,
                        email = userEmail,
                        role = user.role,
                        roles = roles,
                        isEmailVerified = verifiedUser.isEmailVerified,
                        _username = profile?.username ?: user.enrollmentNumber ?: userEmail.substringBefore("@")
                    )

                    val auth = UsernamePasswordAuthenticationToken(principal, null, principal.authorities)
                    SecurityContextHolder.getContext().authentication = auth
                }
            }
        }
        filterChain.doFilter(request, response)
    }
}
