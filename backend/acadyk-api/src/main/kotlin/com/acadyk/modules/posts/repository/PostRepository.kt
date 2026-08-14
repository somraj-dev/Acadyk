package com.acadyk.modules.posts.repository

import com.acadyk.modules.posts.entity.PostEntity
import com.acadyk.modules.posts.entity.PostMediaEntity
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.Optional

@Repository
interface PostRepository : JpaRepository<PostEntity, String> {
    fun findAllByDeletedAtIsNullOrderByCreatedAtDesc(pageable: Pageable): Page<PostEntity>
    fun findAllByAuthorIdAndDeletedAtIsNullOrderByCreatedAtDesc(authorId: String, pageable: Pageable): Page<PostEntity>
    fun findByIdAndDeletedAtIsNull(id: String): Optional<PostEntity>
}

@Repository
interface PostMediaRepository : JpaRepository<PostMediaEntity, String> {
    fun findAllByPostIdOrderByPositionAsc(postId: String): List<PostMediaEntity>
}
