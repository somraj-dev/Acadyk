package com.acadyk.modules.posts.mapper

import com.acadyk.modules.posts.dto.PostAuthorDto
import com.acadyk.modules.posts.dto.PostResponse
import com.acadyk.modules.posts.entity.PostEntity
import com.acadyk.modules.posts.entity.PostMediaEntity
import com.acadyk.modules.users.repository.UserRepository
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Component

@Component
class PostMapper(
    @Autowired(required = false)
    private val userRepository: UserRepository? = null
) {

    fun toResponse(
        entity: PostEntity,
        mediaList: List<PostMediaEntity> = emptyList(),
        isLiked: Boolean = false,
        isBookmarked: Boolean = false
    ): PostResponse {
        val authorEmail = entity.author.email?.takeIf { it.isNotBlank() }
            ?: userRepository?.findById(entity.author.userId)?.map { it.collegeEmail ?: it.email }?.orElse("")
            ?: ""

        return PostResponse(
            id = entity.id.toString(),
            author = PostAuthorDto(
                id = entity.author.id.toString(),
                username = entity.author.username,
                fullName = entity.author.fullName,
                email = authorEmail.takeIf { it.isNotBlank() },
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
