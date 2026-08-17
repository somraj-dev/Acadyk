package com.acadyk.security

import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.Test
import org.springframework.security.core.authority.SimpleGrantedAuthority
import java.util.UUID

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
        val id = UUID.randomUUID()
        val principal = UserPrincipal(
            id = id,
            email = "somraj@acadyk.com",
            role = Role.SUPER_ADMIN
        )

        assertEquals(id, principal.id)
        assertEquals("somraj@acadyk.com", principal.email)
        assertTrue(principal.authorities.contains(SimpleGrantedAuthority("ROLE_SUPER_ADMIN")))
    }
}
