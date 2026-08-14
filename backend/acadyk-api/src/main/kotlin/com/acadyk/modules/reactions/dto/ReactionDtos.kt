package com.acadyk.modules.reactions.dto

data class ToggleReactionResponse(
    val entityId: String,
    val isReacted: Boolean,
    val reactionType: String,
    val totalCount: Int
)

data class BookmarkResponse(
    val postId: String,
    val isBookmarked: Boolean
)
