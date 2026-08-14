package com.acadyk.modules.comments.repository

import com.acadyk.modules.comments.entity.CommentEntity
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.Optional

@Repository
interface CommentRepository : JpaRepository<CommentEntity, String> {
    fun findAllByPostIdAndDeletedAtIsNullOrderByCreatedAtAsc(postId: String, pageable: Pageable): Page<CommentEntity>
    fun findAllByPostIdAndDeletedAtIsNullOrderByCreatedAtAsc(postId: String): List<CommentEntity>
    fun findByIdAndDeletedAtIsNull(id: String): Optional<CommentEntity>
}
