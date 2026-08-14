package com.acadyk.modules.search.repository

import com.acadyk.modules.search.document.*
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.elasticsearch.repository.ElasticsearchRepository
import org.springframework.stereotype.Repository

@Repository
interface ProfileSearchRepository : ElasticsearchRepository<ProfileSearchDocument, String> {
    fun findByFullNameContainingOrCollegeNameContainingOrHeadlineContaining(
        fullName: String,
        collegeName: String,
        headline: String,
        pageable: Pageable
    ): Page<ProfileSearchDocument>

    fun findByCollegeNameIgnoreCase(collegeName: String, pageable: Pageable): Page<ProfileSearchDocument>
    fun findByFullNameStartingWithIgnoreCase(prefix: String, pageable: Pageable): Page<ProfileSearchDocument>
}

@Repository
interface PostSearchRepository : ElasticsearchRepository<PostSearchDocument, String> {
    fun findByContentContaining(keyword: String, pageable: Pageable): Page<PostSearchDocument>
}

@Repository
interface OpportunitySearchRepository : ElasticsearchRepository<OpportunitySearchDocument, String> {
    fun findByTitleContainingOrCompanyNameContainingOrDescriptionContaining(
        title: String,
        companyName: String,
        description: String,
        pageable: Pageable
    ): Page<OpportunitySearchDocument>

    fun findByOpportunityType(opportunityType: String, pageable: Pageable): Page<OpportunitySearchDocument>
}

@Repository
interface EventSearchRepository : ElasticsearchRepository<EventSearchDocument, String> {
    fun findByTitleContainingOrDescriptionContaining(
        title: String,
        description: String,
        pageable: Pageable
    ): Page<EventSearchDocument>

    fun findByEventType(eventType: String, pageable: Pageable): Page<EventSearchDocument>
}

@Repository
interface CommunitySearchRepository : ElasticsearchRepository<CommunitySearchDocument, String> {
    fun findByNameContainingOrDescriptionContaining(
        name: String,
        description: String,
        pageable: Pageable
    ): Page<CommunitySearchDocument>

    fun findByCategory(category: String, pageable: Pageable): Page<CommunitySearchDocument>
}

@Repository
interface StartupSearchRepository : ElasticsearchRepository<StartupSearchDocument, String> {
    fun findByNameContainingOrPitchContaining(
        name: String,
        pitch: String,
        pageable: Pageable
    ): Page<StartupSearchDocument>

    fun findByIndustry(industry: String, pageable: Pageable): Page<StartupSearchDocument>
}

@Repository
interface CompanySearchRepository : ElasticsearchRepository<CompanySearchDocument, String> {
    fun findByNameContainingOrDescriptionContaining(
        name: String,
        description: String,
        pageable: Pageable
    ): Page<CompanySearchDocument>
}
