package com.acadyk.modules.posts.dto

import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Size
import java.time.Instant

data class CreatePostRequest(
    @field:NotBlank(message = "Post content cannot be blank")
    @field:Size(max = 5000, message = "Post content cannot exceed 5000 characters")
    val content: String,

    val postType: String? = "text",
    val visibility: String? = "public",
    val imageUrl: String? = null,
    val mediaUrls: List<String>? = null
)

data class UpdatePostRequest(
    @field:Size(max = 5000, message = "Post content cannot exceed 5000 characters")
    val content: String? = null,
    val postType: String? = null,
    val visibility: String? = null,
    val imageUrl: String? = null,
    val mediaUrls: List<String>? = null
)

data class PostAuthorDto(
    val id: String,
    val username: String,
    val fullName: String,
    val headline: String?,
    val profilePhotoUrl: String?
)

data class PostResponse(
    val id: String,
    val author: PostAuthorDto,
    val content: String,
    val postType: String,
    val visibility: String,
    val imageUrl: String?,
    val mediaUrls: List<String>,
    val likesCount: Int,
    val commentsCount: Int,
    val sharesCount: Int,
    val isLiked: Boolean = false,
    val isBookmarked: Boolean = false,
    val createdAt: Instant,
    val updatedAt: Instant
)
