package com.acadyk.security

enum class Role {
    STUDENT,
    FACULTY,
    COLLEGE_ADMIN,
    COMPANY,
    MODERATOR,
    SUPER_ADMIN;

    val authority: String
        get() = "ROLE_$name"
}
