package com.acadyk.modules.startups.mapper

import com.acadyk.modules.startups.dto.StartupResponse
import com.acadyk.modules.startups.entity.StartupEntity
import com.acadyk.modules.startups.entity.StartupMediaEntity
import org.springframework.stereotype.Component

@Component
class StartupMapper {

    fun toResponse(entity: StartupEntity, mediaList: List<StartupMediaEntity> = emptyList()): StartupResponse {
        return StartupResponse(
            id = entity.id,
            name = entity.name,
            slug = entity.slug,
            pitch = entity.pitch,
            description = entity.description,
            stage = entity.stage,
            industry = entity.industry,
            websiteUrl = entity.websiteUrl,
            logoUrl = entity.logoUrl,
            bannerUrl = entity.bannerUrl,
            teamSize = entity.teamSize,
            founderName = entity.founder.fullName,
            mediaUrls = mediaList.map { it.mediaUrl },
            createdAt = entity.createdAt
        )
    }
}
