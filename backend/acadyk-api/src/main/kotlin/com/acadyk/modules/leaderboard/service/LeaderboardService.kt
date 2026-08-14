package com.acadyk.modules.leaderboard.service

import com.acadyk.common.PageResponse
import com.acadyk.modules.leaderboard.dto.LeaderboardItemResponse
import com.acadyk.modules.leaderboard.mapper.LeaderboardMapper
import com.acadyk.modules.leaderboard.repository.LeaderboardRepository
import org.springframework.data.domain.PageRequest
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@Transactional(readOnly = true)
class LeaderboardService(
    private val leaderboardRepository: LeaderboardRepository,
    private val leaderboardMapper: LeaderboardMapper
) {

    fun getLeaderboard(category: String?, period: String?, page: Int, size: Int): PageResponse<LeaderboardItemResponse> {
        val pageable = PageRequest.of(page, size)
        val result = if (!category.isNullOrBlank() && !period.isNullOrBlank()) {
            leaderboardRepository.findAllByCategoryAndPeriodOrderByScoreDesc(category, period, pageable)
        } else {
            leaderboardRepository.findAllByOrderByScoreDesc(pageable)
        }
        return PageResponse.from(result, leaderboardMapper::toResponse)
    }
}
