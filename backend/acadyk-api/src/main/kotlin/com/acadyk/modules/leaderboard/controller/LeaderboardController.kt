package com.acadyk.modules.leaderboard.controller

import com.acadyk.common.ApiResponse
import com.acadyk.common.PageResponse
import com.acadyk.modules.leaderboard.dto.LeaderboardItemResponse
import com.acadyk.modules.leaderboard.service.LeaderboardService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/v1/leaderboard")
class LeaderboardController(private val leaderboardService: LeaderboardService) {

    @GetMapping
    fun getLeaderboard(
        @RequestParam(required = false) category: String?,
        @RequestParam(required = false) period: String?,
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "20") size: Int
    ): ResponseEntity<ApiResponse<PageResponse<LeaderboardItemResponse>>> {
        val result = leaderboardService.getLeaderboard(category, period, page, size)
        return ResponseEntity.ok(ApiResponse.success(result))
    }
}
