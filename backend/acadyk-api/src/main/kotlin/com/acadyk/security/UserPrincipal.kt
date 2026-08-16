package com.acadyk.security

import org.springframework.security.core.GrantedAuthority
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.core.userdetails.UserDetails

data class UserPrincipal(
    val id: String,
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
