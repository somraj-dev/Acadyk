package com.acadyk.modules.communities.dto

import jakarta.validation.constraints.NotBlank
import java.time.Instant

data class CreateCommunityRequest(
    @field:NotBlank(message = "Community name is required")
    val name: String,

    val description: String? = null,
    val category: String? = "academic",
    val avatarUrl: String? = null,
    val bannerUrl: String? = null,
    val isPrivate: Boolean = false
)

data class CommunityResponse(
    val id: String,
    val name: String,
    val slug: String,
    val description: String?,
    val category: String,
    val avatarUrl: String?,
    val bannerUrl: String?,
    val isPrivate: Boolean,
    val membersCount: Int,
    val isMember: Boolean = false,
    val createdAt: Instant
)
