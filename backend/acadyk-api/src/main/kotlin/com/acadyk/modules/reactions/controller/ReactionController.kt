package com.acadyk.modules.reactions.controller

import com.acadyk.common.ApiResponse
import com.acadyk.modules.reactions.dto.BookmarkResponse
import com.acadyk.modules.reactions.dto.ToggleReactionResponse
import com.acadyk.modules.reactions.service.ReactionService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/v1")
@CrossOrigin(origins = ["*"])
class ReactionController(private val reactionService: ReactionService) {

    @PostMapping("/posts/{postId}/reactions")
    fun togglePostReaction(
        @PathVariable postId: String,
        @RequestParam(defaultValue = "like") type: String
    ): ResponseEntity<ApiResponse<ToggleReactionResponse>> {
        val result = reactionService.togglePostReaction(postId, type)
        return ResponseEntity.ok(ApiResponse.success(result))
    }

    @PostMapping("/posts/{postId}/like")
    fun togglePostLike(@PathVariable postId: String): ResponseEntity<ApiResponse<ToggleReactionResponse>> {
        val result = reactionService.togglePostReaction(postId, "like")
        return ResponseEntity.ok(ApiResponse.success(result))
    }

    @PostMapping("/posts/{postId}/bookmark")
    fun toggleBookmark(@PathVariable postId: String): ResponseEntity<ApiResponse<BookmarkResponse>> {
        val result = reactionService.toggleBookmark(postId)
        return ResponseEntity.ok(ApiResponse.success(result))
    }

    @PostMapping("/comments/{commentId}/reactions")
    fun toggleCommentReaction(
        @PathVariable commentId: String,
        @RequestParam(defaultValue = "like") type: String
    ): ResponseEntity<ApiResponse<ToggleReactionResponse>> {
        val result = reactionService.toggleCommentReaction(commentId, type)
        return ResponseEntity.ok(ApiResponse.success(result))
    }
}
