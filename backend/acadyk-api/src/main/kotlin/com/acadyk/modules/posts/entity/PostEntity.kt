package com.acadyk.modules.posts.entity

import com.acadyk.modules.profiles.entity.ProfileEntity
import jakarta.persistence.*
import java.time.Instant
import java.util.UUID

@Entity
@Table(name = "posts")
data class PostEntity(
    @Id
    val id: UUID = UUID.randomUUID(),

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "author_id", nullable = false)
    val author: ProfileEntity,

    @Column(columnDefinition = "TEXT", nullable = false)
    var content: String,

    var postType: String = "text",
    var visibility: String = "public",
    var imageUrl: String? = null,
    var likesCount: Int = 0,
    var commentsCount: Int = 0,
    var sharesCount: Int = 0,

    @Column(nullable = false)
    val createdAt: Instant = Instant.now(),

    @Column(nullable = false)
    var updatedAt: Instant = Instant.now(),

    var deletedAt: Instant? = null
)

@Entity
@Table(name = "post_media")
data class PostMediaEntity(
    @Id
    val id: UUID = UUID.randomUUID(),

    @Column(nullable = false)
    val postId: UUID,

    @Column(nullable = false)
    val mediaUrl: String,

    var mediaType: String = "image",
    var thumbnailUrl: String? = null,
    var position: Int = 0,
    val createdAt: Instant = Instant.now()
)
