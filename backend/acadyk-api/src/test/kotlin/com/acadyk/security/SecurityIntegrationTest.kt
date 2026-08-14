package com.acadyk.security

import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.Test
import org.springframework.security.core.authority.SimpleGrantedAuthority

class SecurityIntegrationTest {

    @Test
    fun `Role enum contains all required production enterprise roles`() {
        val roles = Role.values().map { it.name }
        assertTrue(roles.contains("STUDENT"))
        assertTrue(roles.contains("FACULTY"))
        assertTrue(roles.contains("COLLEGE_ADMIN"))
        assertTrue(roles.contains("COMPANY"))
        assertTrue(roles.contains("MODERATOR"))
        assertTrue(roles.contains("SUPER_ADMIN"))
    }

    @Test
    fun `UserPrincipal sets correct authorities based on role`() {
        val principal = UserPrincipal(
            id = "user_123",
            email = "somraj@acadyk.com",
            role = Role.SUPER_ADMIN
        )

        assertEquals("user_123", principal.id)
        assertEquals("somraj@acadyk.com", principal.email)
        assertTrue(principal.authorities.contains(SimpleGrantedAuthority("ROLE_SUPER_ADMIN")))
    }
}
