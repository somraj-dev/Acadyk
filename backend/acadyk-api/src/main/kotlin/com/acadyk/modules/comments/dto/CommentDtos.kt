package com.acadyk.modules.comments.dto

import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Size
import java.time.Instant

data class AddCommentRequest(
    @field:NotBlank(message = "Comment content cannot be blank")
    @field:Size(max = 2000, message = "Comment content cannot exceed 2000 characters")
    val content: String,

    val parentId: String? = null
)

data class CommentAuthorDto(
    val id: String,
    val username: String,
    val fullName: String,
    val profilePhotoUrl: String?
)

data class CommentResponse(
    val id: String,
    val postId: String,
    val author: CommentAuthorDto,
    val content: String,
    val parentId: String?,
    val likesCount: Int,
    val createdAt: Instant,
    val updatedAt: Instant
)
