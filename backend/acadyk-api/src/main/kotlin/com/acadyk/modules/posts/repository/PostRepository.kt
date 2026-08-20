package com.acadyk.modules.posts.repository

import com.acadyk.modules.posts.entity.PostEntity
import com.acadyk.modules.posts.entity.PostMediaEntity
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.Optional
import java.util.UUID

@Repository
interface PostRepository : JpaRepository<PostEntity, UUID> {
    fun findAllByDeletedAtIsNullOrderByCreatedAtDesc(pageable: Pageable): Page<PostEntity>
    fun findAllByAuthorIdAndDeletedAtIsNullOrderByCreatedAtDesc(authorId: UUID, pageable: Pageable): Page<PostEntity>
    fun countByAuthorIdAndDeletedAtIsNull(authorId: UUID): Long
    fun findByIdAndDeletedAtIsNull(id: UUID): Optional<PostEntity>
}

@Repository
interface PostMediaRepository : JpaRepository<PostMediaEntity, UUID> {
    fun findAllByPostIdOrderByPositionAsc(postId: UUID): List<PostMediaEntity>
}
