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

    fun hasRole(role: Role): Boolean = try { getCurrentUser().hasRole(role) } catch (_: Exception) { false }

    fun hasAnyRole(vararg roles: Role): Boolean = try {
        val user = getCurrentUser()
        roles.any { user.hasRole(it) }
    } catch (_: Exception) { false }

    fun hasAnyRole(vararg roleNames: String): Boolean = try {
        val user = getCurrentUser()
        val userRoles = (user.roles + listOfNotNull(user.role)).map { it.name }
        roleNames.any { it in userRoles }
    } catch (_: Exception) { false }

    fun isCurrentAdmin(): Boolean = hasAnyRole("SUPER_ADMIN", "COLLEGE_ADMIN")
}
