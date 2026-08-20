package com.acadyk.modules.comments.controller

import com.acadyk.common.ApiResponse
import com.acadyk.common.PageResponse
import com.acadyk.modules.comments.dto.AddCommentRequest
import com.acadyk.modules.comments.dto.CommentResponse
import com.acadyk.modules.comments.service.CommentService
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/v1/posts/{postId}/comments")
class CommentController(private val commentService: CommentService) {

    @GetMapping
    fun getComments(
        @PathVariable postId: String,
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "20") size: Int
    ): ResponseEntity<ApiResponse<PageResponse<CommentResponse>>> {
        val result = commentService.getComments(postId, page, size)
        return ResponseEntity.ok(ApiResponse.success(result))
    }

    @PostMapping
    fun addComment(
        @PathVariable postId: String,
        @Valid @RequestBody request: AddCommentRequest
    ): ResponseEntity<ApiResponse<CommentResponse>> {
        val comment = commentService.addComment(postId, request)
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(ApiResponse.success(comment, "Comment posted successfully"))
    }

    @DeleteMapping("/{commentId}")
    fun deleteComment(
        @PathVariable postId: String,
        @PathVariable commentId: String
    ): ResponseEntity<ApiResponse<Unit>> {
        commentService.deleteComment(postId, commentId)
        return ResponseEntity.ok(ApiResponse.success(Unit, "Comment deleted successfully"))
    }
}
