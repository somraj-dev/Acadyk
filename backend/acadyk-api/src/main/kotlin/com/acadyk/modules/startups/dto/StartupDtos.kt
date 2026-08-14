package com.acadyk.modules.startups.dto

import jakarta.validation.constraints.NotBlank
import java.time.Instant

data class CreateStartupRequest(
    @field:NotBlank(message = "Startup name is required")
    val name: String,

    @field:NotBlank(message = "Pitch is required")
    val pitch: String,

    val description: String? = null,
    val stage: String? = "Idea",
    val industry: String = "Technology",
    val websiteUrl: String? = null,
    val logoUrl: String? = null,
    val bannerUrl: String? = null,
    val mediaUrls: List<String>? = null
)

data class StartupResponse(
    val id: String,
    val name: String,
    val slug: String,
    val pitch: String,
    val description: String?,
    val stage: String,
    val industry: String,
    val websiteUrl: String?,
    val logoUrl: String?,
    val bannerUrl: String?,
    val teamSize: Int,
    val founderName: String,
    val mediaUrls: List<String> = emptyList(),
    val createdAt: Instant
)
