package com.acadyk.modules.reactions.repository

import com.acadyk.modules.reactions.entity.CommentReactionEntity
import com.acadyk.modules.reactions.entity.PostReactionEntity
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.Optional
import java.util.UUID

@Repository
interface PostReactionRepository : JpaRepository<PostReactionEntity, UUID> {
    fun findByPostIdAndUserId(postId: UUID, userId: UUID): Optional<PostReactionEntity>
    fun existsByPostIdAndUserId(postId: UUID, userId: UUID): Boolean
}

@Repository
interface CommentReactionRepository : JpaRepository<CommentReactionEntity, UUID> {
    fun findByCommentIdAndUserId(commentId: UUID, userId: UUID): Optional<CommentReactionEntity>
    fun existsByCommentIdAndUserId(commentId: UUID, userId: UUID): Boolean
}
