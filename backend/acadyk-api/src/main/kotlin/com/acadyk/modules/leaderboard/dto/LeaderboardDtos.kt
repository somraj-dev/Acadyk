package com.acadyk.modules.leaderboard.dto

data class LeaderboardItemResponse(
    val id: String,
    val profileId: String,
    val username: String,
    val fullName: String,
    val profilePhotoUrl: String?,
    val collegeName: String?,
    val score: Int,
    val rank: Int,
    val category: String,
    val period: String
)
