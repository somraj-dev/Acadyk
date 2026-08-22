package com.acadyk.modules.comments.mapper

import com.acadyk.modules.comments.dto.CommentAuthorDto
import com.acadyk.modules.comments.dto.CommentResponse
import com.acadyk.modules.comments.entity.CommentEntity
import com.acadyk.modules.users.repository.UserRepository
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Component

@Component
class CommentMapper(
    @Autowired(required = false)
    private val userRepository: UserRepository? = null
) {

    fun toResponse(entity: CommentEntity): CommentResponse {
        val authorEmail = entity.author.email?.takeIf { it.isNotBlank() }
            ?: userRepository?.findById(entity.author.userId)?.map { it.collegeEmail ?: it.email }?.orElse("")
            ?: ""

        return CommentResponse(
            id = entity.id.toString(),
            postId = entity.post.id.toString(),
            author = CommentAuthorDto(
                id = entity.author.id.toString(),
                username = entity.author.username,
                fullName = entity.author.fullName,
                headline = entity.author.headline,
                email = authorEmail.takeIf { it.isNotBlank() },
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
