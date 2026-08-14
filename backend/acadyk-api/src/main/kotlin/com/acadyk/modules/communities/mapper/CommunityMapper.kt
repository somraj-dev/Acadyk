package com.acadyk.modules.communities.mapper

import com.acadyk.modules.communities.dto.CommunityResponse
import com.acadyk.modules.communities.entity.CommunityEntity
import org.springframework.stereotype.Component

@Component
class CommunityMapper {

    fun toResponse(entity: CommunityEntity, isMember: Boolean = false): CommunityResponse {
        return CommunityResponse(
            id = entity.id,
            name = entity.name,
            slug = entity.slug,
            description = entity.description,
            category = entity.category,
            avatarUrl = entity.avatarUrl,
            bannerUrl = entity.bannerUrl,
            isPrivate = entity.isPrivate,
            membersCount = entity.membersCount,
            isMember = isMember,
            createdAt = entity.createdAt
        )
    }
}
