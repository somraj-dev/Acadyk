package com.acadyk.modules.opportunities.repository

import com.acadyk.modules.opportunities.entity.OpportunityApplicationEntity
import com.acadyk.modules.opportunities.entity.OpportunityEntity
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.Optional
import java.util.UUID

@Repository
interface OpportunityRepository : JpaRepository<OpportunityEntity, UUID> {
    fun findAllByDeletedAtIsNullOrderByCreatedAtDesc(pageable: Pageable): Page<OpportunityEntity>
    fun findAllByOpportunityTypeAndDeletedAtIsNullOrderByCreatedAtDesc(opportunityType: String, pageable: Pageable): Page<OpportunityEntity>
    fun findByIdAndDeletedAtIsNull(id: UUID): Optional<OpportunityEntity>
}

@Repository
interface OpportunityApplicationRepository : JpaRepository<OpportunityApplicationEntity, UUID> {
    fun existsByOpportunityIdAndProfileId(opportunityId: UUID, profileId: UUID): Boolean
    fun findAllByProfileId(profileId: UUID): List<OpportunityApplicationEntity>
}
