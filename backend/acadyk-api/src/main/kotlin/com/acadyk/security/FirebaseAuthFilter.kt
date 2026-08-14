package com.acadyk.security

import com.acadyk.modules.profiles.entity.ProfileEntity
import com.acadyk.modules.profiles.repository.ProfileRepository
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
    private val profileRepository: ProfileRepository
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
                // Look up or provision verified user in DB - strictly using token verified identity
                val profile = profileRepository.findById(verifiedUser.uid).orElseGet {
                    profileRepository.save(
                        ProfileEntity(
                            id = verifiedUser.uid,
                            username = verifiedUser.email.substringBefore("@") + "_" + verifiedUser.uid.takeLast(4),
                            fullName = verifiedUser.name ?: "Acadyk Member",
                            email = verifiedUser.email,
                            profilePhotoUrl = verifiedUser.picture,
                            createdAt = Instant.now(),
                            updatedAt = Instant.now()
                        )
                    )
                }

                // Determine user roles securely from backend
                val roles = mutableSetOf(Role.STUDENT)
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
