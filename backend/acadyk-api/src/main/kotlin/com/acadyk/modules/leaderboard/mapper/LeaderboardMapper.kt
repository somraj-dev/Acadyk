package com.acadyk.modules.leaderboard.mapper

import com.acadyk.modules.leaderboard.dto.LeaderboardItemResponse
import com.acadyk.modules.leaderboard.entity.LeaderboardEntryEntity
import org.springframework.stereotype.Component

@Component
class LeaderboardMapper {

    fun toResponse(entity: LeaderboardEntryEntity): LeaderboardItemResponse {
        return LeaderboardItemResponse(
            id = entity.id,
            profileId = entity.profile.id,
            username = entity.profile.username,
            fullName = entity.profile.fullName,
            profilePhotoUrl = entity.profile.profilePhotoUrl,
            collegeName = entity.profile.collegeName,
            score = entity.score,
            rank = entity.rank,
            category = entity.category,
            period = entity.period
        )
    }
}
