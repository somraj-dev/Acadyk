package com.acadyk.security

import com.acadyk.common.UnauthorizedException
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.stereotype.Component
import java.util.UUID

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

    fun getCurrentUserId(): UUID = getCurrentUser().id

    fun getCurrentUserIdString(): String = getCurrentUser().id.toString()

    fun getCurrentUserEmail(): String = getCurrentUser().email

    fun hasRole(role: Role): Boolean = getCurrentUser().hasRole(role)
}
