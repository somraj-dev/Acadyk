package com.acadyk.modules.leaderboard.repository

import com.acadyk.modules.leaderboard.entity.LeaderboardEntryEntity
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface LeaderboardRepository : JpaRepository<LeaderboardEntryEntity, String> {
    fun findAllByCategoryAndPeriodOrderByScoreDesc(category: String, period: String, pageable: Pageable): Page<LeaderboardEntryEntity>
    fun findAllByOrderByScoreDesc(pageable: Pageable): Page<LeaderboardEntryEntity>
}
