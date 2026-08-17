package com.acadyk.modules.opportunities.mapper

import com.acadyk.modules.opportunities.dto.OpportunityResponse
import com.acadyk.modules.opportunities.entity.OpportunityEntity
import org.springframework.stereotype.Component

@Component
class OpportunityMapper {

    fun toResponse(entity: OpportunityEntity, isApplied: Boolean = false): OpportunityResponse {
        return OpportunityResponse(
            id = entity.id.toString(),
            companyName = entity.companyName,
            title = entity.title,
            slug = entity.slug,
            opportunityType = entity.opportunityType,
            description = entity.description,
            requirements = entity.requirements,
            location = entity.location,
            isRemote = entity.isRemote,
            stipendOrSalary = entity.stipendOrSalary,
            deadline = entity.deadline,
            applyUrl = entity.applyUrl,
            applicationsCount = entity.applicationsCount,
            isApplied = isApplied,
            createdAt = entity.createdAt
        )
    }
}
