package com.acadyk.modules.search.service

import com.acadyk.modules.communities.service.CommunityService
import com.acadyk.modules.events.service.EventService
import com.acadyk.modules.opportunities.service.OpportunityService
import com.acadyk.modules.posts.service.PostService
import com.acadyk.modules.profiles.service.ProfileService
import com.acadyk.modules.search.dto.AutocompleteSuggestion
import com.acadyk.modules.search.dto.GlobalSearchResponse
import com.acadyk.modules.search.dto.SearchFilterParams
import com.acadyk.modules.startups.service.StartupService
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@Transactional(readOnly = true)
class SearchService(
    private val profileService: ProfileService,
    private val postService: PostService,
    private val opportunityService: OpportunityService,
    private val eventService: EventService,
    private val communityService: CommunityService,
    private val startupService: StartupService
) {
    private val logger = LoggerFactory.getLogger(javaClass)

    /**
     * Multi-field full-text search powered by PostgreSQL with pg_trgm indexes.
     * Searches profiles, posts, opportunities, events, communities, and startups
     * directly from PostgreSQL relational tables.
     */
    fun search(params: SearchFilterParams): GlobalSearchResponse {
        val trimmed = params.query.trim()
        val requestedType = params.type?.lowercase() ?: "all"

        val profiles = if (requestedType == "all" || requestedType == "profile") {
            profileService.searchProfiles(trimmed, params.page, params.size).content
        } else emptyList()

        val opportunities = if (requestedType == "all" || requestedType == "opportunity") {
            opportunityService.getOpportunities(params.opportunityType, params.page, params.size).content.filter {
                trimmed.isBlank() || it.title.contains(trimmed, ignoreCase = true) || it.companyName.contains(trimmed, ignoreCase = true)
            }
        } else emptyList()

        val events = if (requestedType == "all" || requestedType == "event") {
            eventService.getEvents(params.category, params.page, params.size).content.filter {
                trimmed.isBlank() || it.title.contains(trimmed, ignoreCase = true)
            }
        } else emptyList()

        val communities = if (requestedType == "all" || requestedType == "community") {
            communityService.getCommunities(params.category, params.page, params.size).content.filter {
                trimmed.isBlank() || it.name.contains(trimmed, ignoreCase = true)
            }
        } else emptyList()

        val startups = if (requestedType == "all" || requestedType == "startup") {
            startupService.getStartups(null, params.page, params.size).content.filter {
                trimmed.isBlank() || it.name.contains(trimmed, ignoreCase = true)
            }
        } else emptyList()

        val posts = if (requestedType == "all" || requestedType == "post") {
            postService.getPosts(params.page, params.size).content.filter {
                trimmed.isBlank() || it.content.contains(trimmed, ignoreCase = true) || it.author.fullName.contains(trimmed, ignoreCase = true)
            }
        } else emptyList()

        val totalHits = (profiles.size + posts.size + opportunities.size + events.size + communities.size + startups.size).toLong()

        return GlobalSearchResponse(
            query = trimmed,
            totalHits = totalHits,
            profiles = profiles,
            posts = posts,
            opportunities = opportunities,
            events = events,
            communities = communities,
            startups = startups
        )
    }

    /**
     * Autocomplete suggestions powered by PostgreSQL profile search with pg_trgm indexes.
     */
    fun autocomplete(query: String): List<AutocompleteSuggestion> {
        val trimmed = query.trim()
        if (trimmed.length < 2) return emptyList()

        val suggestions = mutableListOf<AutocompleteSuggestion>()
        profileService.searchProfiles(trimmed, 0, 5).content.forEach {
            suggestions.add(AutocompleteSuggestion(it.id, it.fullName, it.headline, "profile", it.profilePhotoUrl))
        }
        return suggestions
    }
}
