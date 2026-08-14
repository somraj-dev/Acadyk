package com.acadyk.modules.reactions.service

import com.acadyk.common.ResourceNotFoundException
import com.acadyk.infrastructure.kafka.DomainEventPublisher
import com.acadyk.infrastructure.kafka.PostLikedEvent
import com.acadyk.modules.comments.repository.CommentRepository
import com.acadyk.modules.posts.repository.PostRepository
import com.acadyk.modules.profiles.repository.ProfileRepository
import com.acadyk.modules.reactions.dto.BookmarkResponse
import com.acadyk.modules.reactions.dto.ToggleReactionResponse
import com.acadyk.modules.reactions.entity.CommentReactionEntity
import com.acadyk.modules.reactions.entity.PostReactionEntity
import com.acadyk.modules.reactions.repository.CommentReactionRepository
import com.acadyk.modules.reactions.repository.PostReactionRepository
import com.acadyk.security.CurrentUserProvider
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@Transactional
class ReactionService(
    private val postReactionRepository: PostReactionRepository,
    private val commentReactionRepository: CommentReactionRepository,
    private val postRepository: PostRepository,
    private val commentRepository: CommentRepository,
    private val profileRepository: ProfileRepository,
    private val currentUserProvider: CurrentUserProvider,
    private val domainEventPublisher: DomainEventPublisher
) {

    fun togglePostReaction(postId: String, reactionType: String = "like"): ToggleReactionResponse {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val post = postRepository.findByIdAndDeletedAtIsNull(postId)
            .orElseThrow { ResourceNotFoundException("Post with id $postId not found") }

        val existing = postReactionRepository.findByPostIdAndUserId(postId, currentUserId)
        val isReacted: Boolean

        if (existing.isPresent) {
            postReactionRepository.delete(existing.get())
            post.likesCount = maxOf(0, post.likesCount - 1)
            isReacted = false
        } else {
            val user = profileRepository.findById(currentUserId)
                .orElseThrow { ResourceNotFoundException("User profile not found") }

            postReactionRepository.save(
                PostReactionEntity(post = post, user = user, reactionType = reactionType)
            )
            post.likesCount += 1
            isReacted = true

            domainEventPublisher.publishPostLiked(
                PostLikedEvent(
                    postId = post.id,
                    authorId = post.author.id,
                    likerId = user.id,
                    likerName = user.fullName
                )
            )
        }

        postRepository.save(post)
        return ToggleReactionResponse(postId, isReacted, reactionType, post.likesCount)
    }

    fun toggleCommentReaction(commentId: String, reactionType: String = "like"): ToggleReactionResponse {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val comment = commentRepository.findByIdAndDeletedAtIsNull(commentId)
            .orElseThrow { ResourceNotFoundException("Comment with id $commentId not found") }

        val existing = commentReactionRepository.findByCommentIdAndUserId(commentId, currentUserId)
        val isReacted: Boolean

        if (existing.isPresent) {
            commentReactionRepository.delete(existing.get())
            comment.likesCount = maxOf(0, comment.likesCount - 1)
            isReacted = false
        } else {
            val user = profileRepository.findById(currentUserId)
                .orElseThrow { ResourceNotFoundException("User profile not found") }

            commentReactionRepository.save(
                CommentReactionEntity(comment = comment, user = user, reactionType = reactionType)
            )
            comment.likesCount += 1
            isReacted = true
        }

        commentRepository.save(comment)
        return ToggleReactionResponse(commentId, isReacted, reactionType, comment.likesCount)
    }

    fun toggleBookmark(postId: String): BookmarkResponse {
        return BookmarkResponse(postId, true)
    }
}
