package com.acadyk.modules.search.dto

import com.acadyk.modules.communities.dto.CommunityResponse
import com.acadyk.modules.events.dto.EventResponse
import com.acadyk.modules.opportunities.dto.OpportunityResponse
import com.acadyk.modules.posts.dto.PostResponse
import com.acadyk.modules.profiles.dto.ProfileResponse
import com.acadyk.modules.startups.dto.StartupResponse

data class SearchFilterParams(
    val query: String = "",
    val type: String? = null, // "all", "profile", "post", "opportunity", "event", "community", "startup"
    val college: String? = null,
    val location: String? = null,
    val skills: List<String>? = null,
    val category: String? = null,
    val date: String? = null,
    val experience: String? = null,
    val opportunityType: String? = null,
    val page: Int = 0,
    val size: Int = 20,
    val sort: String = "relevance"
)

data class AutocompleteSuggestion(
    val id: String,
    val title: String,
    val subtitle: String?,
    val type: String,
    val avatarUrl: String?
)

data class GlobalSearchResponse(
    val query: String,
    val totalHits: Long = 0,
    val profiles: List<ProfileResponse> = emptyList(),
    val posts: List<PostResponse> = emptyList(),
    val opportunities: List<OpportunityResponse> = emptyList(),
    val events: List<EventResponse> = emptyList(),
    val communities: List<CommunityResponse> = emptyList(),
    val startups: List<StartupResponse> = emptyList()
)
