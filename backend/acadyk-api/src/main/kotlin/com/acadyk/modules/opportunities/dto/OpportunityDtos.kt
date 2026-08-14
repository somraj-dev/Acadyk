package com.acadyk.modules.opportunities.dto

import jakarta.validation.constraints.NotBlank
import java.time.Instant

data class CreateOpportunityRequest(
    @field:NotBlank(message = "Title is required")
    val title: String,

    @field:NotBlank(message = "Company name is required")
    val companyName: String,

    @field:NotBlank(message = "Description is required")
    val description: String,

    val opportunityType: String? = "INTERNSHIP",
    val requirements: String? = null,
    val location: String? = null,
    val isRemote: Boolean = false,
    val stipendOrSalary: String? = null,
    val deadline: Instant? = null,
    val applyUrl: String? = null
)

data class ApplyOpportunityRequest(
    val resumeId: String? = null,
    val coverNote: String? = null
)

data class OpportunityResponse(
    val id: String,
    val companyName: String,
    val title: String,
    val slug: String,
    val opportunityType: String,
    val description: String,
    val requirements: String?,
    val location: String?,
    val isRemote: Boolean,
    val stipendOrSalary: String?,
    val deadline: Instant?,
    val applyUrl: String?,
    val applicationsCount: Int,
    val isApplied: Boolean = false,
    val createdAt: Instant
)
