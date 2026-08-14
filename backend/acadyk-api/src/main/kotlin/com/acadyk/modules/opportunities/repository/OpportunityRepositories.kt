package com.acadyk.modules.opportunities.repository

import com.acadyk.modules.opportunities.entity.OpportunityApplicationEntity
import com.acadyk.modules.opportunities.entity.OpportunityEntity
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.Optional

@Repository
interface OpportunityRepository : JpaRepository<OpportunityEntity, String> {
    fun findAllByDeletedAtIsNullOrderByCreatedAtDesc(pageable: Pageable): Page<OpportunityEntity>
    fun findAllByOpportunityTypeAndDeletedAtIsNullOrderByCreatedAtDesc(opportunityType: String, pageable: Pageable): Page<OpportunityEntity>
    fun findByIdAndDeletedAtIsNull(id: String): Optional<OpportunityEntity>
}

@Repository
interface OpportunityApplicationRepository : JpaRepository<OpportunityApplicationEntity, String> {
    fun existsByOpportunityIdAndProfileId(opportunityId: String, profileId: String): Boolean
    fun findAllByProfileId(profileId: String): List<OpportunityApplicationEntity>
}
