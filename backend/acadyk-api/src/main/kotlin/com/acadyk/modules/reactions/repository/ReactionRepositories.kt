package com.acadyk.modules.reactions.repository

import com.acadyk.modules.reactions.entity.CommentReactionEntity
import com.acadyk.modules.reactions.entity.PostReactionEntity
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.Optional

@Repository
interface PostReactionRepository : JpaRepository<PostReactionEntity, String> {
    fun findByPostIdAndUserId(postId: String, userId: String): Optional<PostReactionEntity>
    fun existsByPostIdAndUserId(postId: String, userId: String): Boolean
}

@Repository
interface CommentReactionRepository : JpaRepository<CommentReactionEntity, String> {
    fun findByCommentIdAndUserId(commentId: String, userId: String): Optional<CommentReactionEntity>
    fun existsByCommentIdAndUserId(commentId: String, userId: String): Boolean
}
