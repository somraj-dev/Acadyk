package com.acadyk.modules.comments.mapper

import com.acadyk.modules.comments.dto.CommentAuthorDto
import com.acadyk.modules.comments.dto.CommentResponse
import com.acadyk.modules.comments.entity.CommentEntity
import org.springframework.stereotype.Component

@Component
class CommentMapper {

    fun toResponse(entity: CommentEntity): CommentResponse {
        return CommentResponse(
            id = entity.id.toString(),
            postId = entity.post.id.toString(),
            author = CommentAuthorDto(
                id = entity.author.id.toString(),
                username = entity.author.username,
                fullName = entity.author.fullName,
                profilePhotoUrl = entity.author.profilePhotoUrl
            ),
            content = entity.content,
            parentId = entity.parentId?.toString(),
            likesCount = entity.likesCount,
            createdAt = entity.createdAt,
            updatedAt = entity.updatedAt
        )
    }
}
