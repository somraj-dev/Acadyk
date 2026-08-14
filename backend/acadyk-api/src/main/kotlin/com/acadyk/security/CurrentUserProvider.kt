package com.acadyk.security

import com.acadyk.common.UnauthorizedException
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.stereotype.Component

@Component
class CurrentUserProvider {

    fun getCurrentUser(): UserPrincipal {
        val authentication = SecurityContextHolder.getContext().authentication
            ?: throw UnauthorizedException("User is not authenticated")

        val principal = authentication.principal
        if (principal is UserPrincipal) {
            return principal
        }
        throw UnauthorizedException("Invalid authentication principal")
    }

    fun getCurrentUserId(): String = getCurrentUser().id

    fun getCurrentUserEmail(): String = getCurrentUser().email

    fun hasRole(role: Role): Boolean = getCurrentUser().hasRole(role)
}
