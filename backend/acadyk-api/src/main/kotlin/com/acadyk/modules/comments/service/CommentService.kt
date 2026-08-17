package com.acadyk.modules.comments.service

import com.acadyk.common.PageResponse
import com.acadyk.common.ResourceNotFoundException
import com.acadyk.common.toUUID
import com.acadyk.common.toUUIDOrNull
import com.acadyk.infrastructure.kafka.CommentCreatedEvent
import com.acadyk.infrastructure.kafka.DomainEventPublisher
import com.acadyk.modules.comments.dto.AddCommentRequest
import com.acadyk.modules.comments.dto.CommentResponse
import com.acadyk.modules.comments.entity.CommentEntity
import com.acadyk.modules.comments.mapper.CommentMapper
import com.acadyk.modules.comments.repository.CommentRepository
import com.acadyk.modules.posts.repository.PostRepository
import com.acadyk.modules.profiles.repository.ProfileRepository
import com.acadyk.security.CurrentUserProvider
import org.springframework.data.domain.PageRequest
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

@Service
@Transactional
class CommentService(
    private val commentRepository: CommentRepository,
    private val postRepository: PostRepository,
    private val profileRepository: ProfileRepository,
    private val commentMapper: CommentMapper,
    private val currentUserProvider: CurrentUserProvider,
    private val domainEventPublisher: DomainEventPublisher
) {

    @Transactional(readOnly = true)
    fun getComments(postId: UUID, page: Int, size: Int): PageResponse<CommentResponse> {
        val pageable = PageRequest.of(page, size)
        val commentsPage = commentRepository.findAllByPostIdAndDeletedAtIsNullOrderByCreatedAtAsc(postId, pageable)
        return PageResponse.from(commentsPage, commentMapper::toResponse)
    }

    @Transactional(readOnly = true)
    fun getComments(postId: String, page: Int, size: Int): PageResponse<CommentResponse> =
        getComments(postId.toUUID(), page, size)

    fun addComment(postId: UUID, request: AddCommentRequest): CommentResponse {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val post = postRepository.findByIdAndDeletedAtIsNull(postId)
            .orElseThrow { ResourceNotFoundException("Post with id $postId not found") }

        val author = profileRepository.findById(currentUserId)
            .orElseThrow { ResourceNotFoundException("User profile not found") }

        val comment = CommentEntity(
            post = post,
            author = author,
            content = request.content,
            parentId = request.parentId?.toUUIDOrNull()
        )
        val savedComment = commentRepository.save(comment)

        post.commentsCount += 1
        postRepository.save(post)

        domainEventPublisher.publishCommentCreated(
            CommentCreatedEvent(
                commentId = savedComment.id.toString(),
                postId = postId.toString(),
                postAuthorId = post.author.id.toString(),
                commenterId = author.id.toString(),
                commenterName = author.fullName,
                contentSnippet = savedComment.content.take(100)
            )
        )

        return commentMapper.toResponse(savedComment)
    }

    fun addComment(postId: String, request: AddCommentRequest): CommentResponse =
        addComment(postId.toUUID(), request)
}
