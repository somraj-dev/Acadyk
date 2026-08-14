package com.acadyk.modules.clubs.dto

import jakarta.validation.constraints.NotBlank
import java.time.Instant

data class CreateClubRequest(
    @field:NotBlank(message = "Club name is required")
    val name: String,

    val collegeName: String? = null,
    val description: String? = null,
    val category: String? = "Technical",
    val logoUrl: String? = null,
    val bannerUrl: String? = null
)

data class ClubResponse(
    val id: String,
    val collegeName: String?,
    val name: String,
    val slug: String,
    val description: String?,
    val category: String,
    val logoUrl: String?,
    val bannerUrl: String?,
    val membersCount: Int,
    val isMember: Boolean = false,
    val createdAt: Instant
)
