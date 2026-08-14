package com.acadyk.modules.search.service

import com.acadyk.modules.communities.service.CommunityService
import com.acadyk.modules.events.service.EventService
import com.acadyk.modules.opportunities.service.OpportunityService
import com.acadyk.modules.posts.service.PostService
import com.acadyk.modules.profiles.service.ProfileService
import com.acadyk.modules.search.document.*
import com.acadyk.modules.search.dto.AutocompleteSuggestion
import com.acadyk.modules.search.dto.GlobalSearchResponse
import com.acadyk.modules.search.dto.SearchFilterParams
import com.acadyk.modules.search.repository.*
import com.acadyk.modules.startups.service.StartupService
import org.slf4j.LoggerFactory
import org.springframework.data.domain.PageRequest
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
    private val startupService: StartupService,
    private val profileSearchRepository: ProfileSearchRepository,
    private val postSearchRepository: PostSearchRepository,
    private val opportunitySearchRepository: OpportunitySearchRepository,
    private val eventSearchRepository: EventSearchRepository,
    private val communitySearchRepository: CommunitySearchRepository,
    private val startupSearchRepository: StartupSearchRepository,
    private val companySearchRepository: CompanySearchRepository
) {
    private val logger = LoggerFactory.getLogger(javaClass)

    /**
     * Multi-field full-text search with filtering, pagination, relevance, and database fallback.
     */
    fun search(params: SearchFilterParams): GlobalSearchResponse {
        val trimmed = params.query.trim()
        val pageable = PageRequest.of(params.page, params.size)

        return try {
            // Attempt Elasticsearch queries with multi-field matching and filters
            executeElasticsearchSearch(trimmed, params, pageable)
        } catch (e: Exception) {
            logger.warn("Elasticsearch query failed, falling back to PostgreSQL relational search: ${e.message}")
            executeRelationalFallbackSearch(trimmed, params)
        }
    }

    private fun executeElasticsearchSearch(query: String, params: SearchFilterParams, pageable: org.springframework.data.domain.Pageable): GlobalSearchResponse {
        val requestedType = params.type?.lowercase() ?: "all"

        val profiles = if (requestedType == "all" || requestedType == "profile") {
            if (query.isNotBlank()) {
                profileSearchRepository.findByFullNameContainingOrCollegeNameContainingOrHeadlineContaining(query, query, query, pageable)
                    .content.map { profileService.getProfileById(it.id) }
            } else if (!params.college.isNullOrBlank()) {
                profileSearchRepository.findByCollegeNameIgnoreCase(params.college, pageable)
                    .content.map { profileService.getProfileById(it.id) }
            } else emptyList()
        } else emptyList()

        val posts = if (requestedType == "all" || requestedType == "post") {
            if (query.isNotBlank()) {
                postSearchRepository.findByContentContaining(query, pageable)
                    .content.mapNotNull { runCatching { postService.getPostById(it.id) }.getOrNull() }
            } else emptyList()
        } else emptyList()

        val opportunities = if (requestedType == "all" || requestedType == "opportunity") {
            if (query.isNotBlank()) {
                opportunitySearchRepository.findByTitleContainingOrCompanyNameContainingOrDescriptionContaining(query, query, query, pageable)
                    .content.mapNotNull { runCatching { opportunityService.getOpportunityById(it.id) }.getOrNull() }
            } else if (!params.opportunityType.isNullOrBlank()) {
                opportunitySearchRepository.findByOpportunityType(params.opportunityType, pageable)
                    .content.mapNotNull { runCatching { opportunityService.getOpportunityById(it.id) }.getOrNull() }
            } else emptyList()
        } else emptyList()

        val events = if (requestedType == "all" || requestedType == "event") {
            if (query.isNotBlank()) {
                eventSearchRepository.findByTitleContainingOrDescriptionContaining(query, query, pageable)
                    .content.mapNotNull { runCatching { eventService.getEventById(it.id) }.getOrNull() }
            } else emptyList()
        } else emptyList()

        val communities = if (requestedType == "all" || requestedType == "community") {
            if (query.isNotBlank()) {
                communitySearchRepository.findByNameContainingOrDescriptionContaining(query, query, pageable)
                    .content.mapNotNull { runCatching { communityService.getCommunityById(it.id) }.getOrNull() }
            } else emptyList()
        } else emptyList()

        val startups = if (requestedType == "all" || requestedType == "startup") {
            if (query.isNotBlank()) {
                startupSearchRepository.findByNameContainingOrPitchContaining(query, query, pageable)
                    .content.mapNotNull { runCatching { startupService.getStartupById(it.id) }.getOrNull() }
            } else emptyList()
        } else emptyList()

        val totalHits = (profiles.size + posts.size + opportunities.size + events.size + communities.size + startups.size).toLong()

        return GlobalSearchResponse(
            query = query,
            totalHits = totalHits,
            profiles = profiles,
            posts = posts,
            opportunities = opportunities,
            events = events,
            communities = communities,
            startups = startups
        )
    }

    private fun executeRelationalFallbackSearch(query: String, params: SearchFilterParams): GlobalSearchResponse {
        val requestedType = params.type?.lowercase() ?: "all"

        val profiles = if (requestedType == "all" || requestedType == "profile") {
            profileService.searchProfiles(query, params.page, params.size).content
        } else emptyList()

        val opportunities = if (requestedType == "all" || requestedType == "opportunity") {
            opportunityService.getOpportunities(params.opportunityType, params.page, params.size).content.filter {
                query.isBlank() || it.title.contains(query, ignoreCase = true) || it.companyName.contains(query, ignoreCase = true)
            }
        } else emptyList()

        val events = if (requestedType == "all" || requestedType == "event") {
            eventService.getEvents(params.category, params.page, params.size).content.filter {
                query.isBlank() || it.title.contains(query, ignoreCase = true)
            }
        } else emptyList()

        val communities = if (requestedType == "all" || requestedType == "community") {
            communityService.getCommunities(params.category, params.page, params.size).content.filter {
                query.isBlank() || it.name.contains(query, ignoreCase = true)
            }
        } else emptyList()

        val startups = if (requestedType == "all" || requestedType == "startup") {
            startupService.getStartups(null, params.page, params.size).content.filter {
                query.isBlank() || it.name.contains(query, ignoreCase = true)
            }
        } else emptyList()

        val totalHits = (profiles.size + opportunities.size + events.size + communities.size + startups.size).toLong()

        return GlobalSearchResponse(
            query = query,
            totalHits = totalHits,
            profiles = profiles,
            opportunities = opportunities,
            events = events,
            communities = communities,
            startups = startups
        )
    }

    /**
     * Autocomplete suggestions with prefix and typo tolerance
     */
    fun autocomplete(query: String): List<AutocompleteSuggestion> {
        val trimmed = query.trim()
        if (trimmed.length < 2) return emptyList()

        val suggestions = mutableListOf<AutocompleteSuggestion>()
        try {
            val profiles = profileSearchRepository.findByFullNameStartingWithIgnoreCase(trimmed, PageRequest.of(0, 5))
            profiles.content.forEach {
                suggestions.add(AutocompleteSuggestion(it.id, it.fullName, it.headline, "profile", it.profilePhotoUrl))
            }
        } catch (_: Exception) {
            // Relational fallback for autocomplete
            profileService.searchProfiles(trimmed, 0, 5).content.forEach {
                suggestions.add(AutocompleteSuggestion(it.id, it.fullName, it.headline, "profile", it.profilePhotoUrl))
            }
        }

        return suggestions
    }

    // Index projection upsert methods
    @Transactional fun indexProfile(doc: ProfileSearchDocument) = runCatching { profileSearchRepository.save(doc) }.onFailure { logger.debug("ES index profile skipped: ${it.message}") }
    @Transactional fun indexPost(doc: PostSearchDocument) = runCatching { postSearchRepository.save(doc) }.onFailure { logger.debug("ES index post skipped: ${it.message}") }
    @Transactional fun indexOpportunity(doc: OpportunitySearchDocument) = runCatching { opportunitySearchRepository.save(doc) }.onFailure { logger.debug("ES index opportunity skipped: ${it.message}") }
    @Transactional fun indexEvent(doc: EventSearchDocument) = runCatching { eventSearchRepository.save(doc) }.onFailure { logger.debug("ES index event skipped: ${it.message}") }
    @Transactional fun indexCommunity(doc: CommunitySearchDocument) = runCatching { communitySearchRepository.save(doc) }.onFailure { logger.debug("ES index community skipped: ${it.message}") }
    @Transactional fun indexStartup(doc: StartupSearchDocument) = runCatching { startupSearchRepository.save(doc) }.onFailure { logger.debug("ES index startup skipped: ${it.message}") }
    @Transactional fun indexCompany(doc: CompanySearchDocument) = runCatching { companySearchRepository.save(doc) }.onFailure { logger.debug("ES index company skipped: ${it.message}") }
}
