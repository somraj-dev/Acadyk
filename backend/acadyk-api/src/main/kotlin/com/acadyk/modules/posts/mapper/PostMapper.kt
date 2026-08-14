package com.acadyk.modules.posts.mapper

import com.acadyk.modules.posts.dto.PostAuthorDto
import com.acadyk.modules.posts.dto.PostResponse
import com.acadyk.modules.posts.entity.PostEntity
import com.acadyk.modules.posts.entity.PostMediaEntity
import org.springframework.stereotype.Component

@Component
class PostMapper {

    fun toResponse(
        entity: PostEntity,
        mediaList: List<PostMediaEntity> = emptyList(),
        isLiked: Boolean = false,
        isBookmarked: Boolean = false
    ): PostResponse {
        return PostResponse(
            id = entity.id,
            author = PostAuthorDto(
                id = entity.author.id,
                username = entity.author.username,
                fullName = entity.author.fullName,
                headline = entity.author.headline,
                profilePhotoUrl = entity.author.profilePhotoUrl
            ),
            content = entity.content,
            postType = entity.postType,
            visibility = entity.visibility,
            imageUrl = entity.imageUrl,
            mediaUrls = mediaList.map { it.mediaUrl },
            likesCount = entity.likesCount,
            commentsCount = entity.commentsCount,
            sharesCount = entity.sharesCount,
            isLiked = isLiked,
            isBookmarked = isBookmarked,
            createdAt = entity.createdAt,
            updatedAt = entity.updatedAt
        )
    }
}
