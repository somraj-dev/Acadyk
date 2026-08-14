package com.acadyk.modules.comments.mapper

import com.acadyk.modules.comments.dto.CommentAuthorDto
import com.acadyk.modules.comments.dto.CommentResponse
import com.acadyk.modules.comments.entity.CommentEntity
import org.springframework.stereotype.Component

@Component
class CommentMapper {

    fun toResponse(entity: CommentEntity): CommentResponse {
        return CommentResponse(
            id = entity.id,
            postId = entity.post.id,
            author = CommentAuthorDto(
                id = entity.author.id,
                username = entity.author.username,
                fullName = entity.author.fullName,
                profilePhotoUrl = entity.author.profilePhotoUrl
            ),
            content = entity.content,
            parentId = entity.parentId,
            likesCount = entity.likesCount,
            createdAt = entity.createdAt,
            updatedAt = entity.updatedAt
        )
    }
}
