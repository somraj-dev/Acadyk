package com.acadyk.modules.reactions.entity

import com.acadyk.modules.comments.entity.CommentEntity
import com.acadyk.modules.posts.entity.PostEntity
import com.acadyk.modules.profiles.entity.ProfileEntity
import jakarta.persistence.*
import java.time.Instant
import java.util.UUID

@Entity
@Table(name = "post_reactions")
data class PostReactionEntity(
    @Id
    val id: UUID = UUID.randomUUID(),

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "post_id", nullable = false)
    val post: PostEntity,

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    val user: ProfileEntity,

    var reactionType: String = "like",

    @Column(nullable = false)
    val createdAt: Instant = Instant.now()
)

@Entity
@Table(name = "comment_reactions")
data class CommentReactionEntity(
    @Id
    val id: UUID = UUID.randomUUID(),

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "comment_id", nullable = false)
    val comment: CommentEntity,

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    val user: ProfileEntity,

    var reactionType: String = "like",

    @Column(nullable = false)
    val createdAt: Instant = Instant.now()
)
