package com.acadyk.modules.comments.repository

import com.acadyk.modules.comments.entity.CommentEntity
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.Optional
import java.util.UUID

@Repository
interface CommentRepository : JpaRepository<CommentEntity, UUID> {
    fun findAllByPostIdAndDeletedAtIsNullOrderByCreatedAtAsc(postId: UUID, pageable: Pageable): Page<CommentEntity>
    fun findAllByPostIdAndDeletedAtIsNullOrderByCreatedAtAsc(postId: UUID): List<CommentEntity>
    fun findByIdAndDeletedAtIsNull(id: UUID): Optional<CommentEntity>
}
