package com.acadyk.modules.clubs.mapper

import com.acadyk.modules.clubs.dto.ClubResponse
import com.acadyk.modules.clubs.entity.ClubEntity
import org.springframework.stereotype.Component

@Component
class ClubMapper {

    fun toResponse(entity: ClubEntity, isMember: Boolean = false): ClubResponse {
        return ClubResponse(
            id = entity.id,
            collegeName = entity.collegeName,
            name = entity.name,
            slug = entity.slug,
            description = entity.description,
            category = entity.category,
            logoUrl = entity.logoUrl,
            bannerUrl = entity.bannerUrl,
            membersCount = entity.membersCount,
            isMember = isMember,
            createdAt = entity.createdAt
        )
    }
}
