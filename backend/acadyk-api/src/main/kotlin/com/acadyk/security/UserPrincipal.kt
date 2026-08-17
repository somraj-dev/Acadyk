package com.acadyk.security

import org.springframework.security.core.GrantedAuthority
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.core.userdetails.UserDetails
import java.util.UUID

data class UserPrincipal(
    val id: UUID,
    val email: String,
    val role: Role? = null,
    val roles: Set<Role> = if (role != null) setOf(role) else setOf(Role.STUDENT),
    val isEmailVerified: Boolean = true,
    private val _username: String? = null
) : UserDetails {

    constructor(
        id: String,
        email: String,
        username: String,
        roles: Set<Role> = setOf(Role.STUDENT),
        isEmailVerified: Boolean = true
    ) : this(
        id = try { UUID.fromString(id) } catch (_: Exception) { UUID.nameUUIDFromBytes(id.toByteArray()) },
        email = email,
        role = null,
        roles = roles,
        isEmailVerified = isEmailVerified,
        _username = username
    )

    constructor(
        id: UUID,
        email: String,
        username: String,
        roles: Set<Role> = setOf(Role.STUDENT),
        isEmailVerified: Boolean = true
    ) : this(
        id = id,
        email = email,
        role = null,
        roles = roles,
        isEmailVerified = isEmailVerified,
        _username = username
    )

    override fun getAuthorities(): Collection<GrantedAuthority> {
        val effectiveRoles = if (role != null) roles + role else roles
        return effectiveRoles.map { SimpleGrantedAuthority(it.authority) }
    }

    override fun getPassword(): String = ""

    override fun getUsername(): String = _username ?: email

    override fun isAccountNonExpired(): Boolean = true

    override fun isAccountNonLocked(): Boolean = true

    override fun isCredentialsNonExpired(): Boolean = true

    override fun isEnabled(): Boolean = true

    fun hasRole(role: Role): Boolean = roles.contains(role) || this.role == role
}
