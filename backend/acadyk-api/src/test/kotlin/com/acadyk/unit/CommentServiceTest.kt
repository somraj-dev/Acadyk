package com.acadyk.unit

import com.acadyk.common.ForbiddenException
import com.acadyk.infrastructure.kafka.DomainEventPublisher
import com.acadyk.modules.comments.dto.AddCommentRequest
import com.acadyk.modules.comments.entity.CommentEntity
import com.acadyk.modules.comments.mapper.CommentMapper
import com.acadyk.modules.comments.repository.CommentRepository
import com.acadyk.modules.comments.service.CommentService
import com.acadyk.modules.posts.entity.PostEntity
import com.acadyk.modules.posts.repository.PostRepository
import com.acadyk.modules.profiles.entity.ProfileEntity
import com.acadyk.modules.profiles.mapper.ProfileMapper
import com.acadyk.modules.profiles.repository.ProfileRepository
import com.acadyk.security.CurrentUserProvider
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import org.mockito.Mockito.*
import java.util.Optional
import java.util.UUID

class CommentServiceTest {

    private lateinit var commentRepository: CommentRepository
    private lateinit var postRepository: PostRepository
    private lateinit var profileRepository: ProfileRepository
    private lateinit var commentMapper: CommentMapper
    private lateinit var currentUserProvider: CurrentUserProvider
    private lateinit var domainEventPublisher: DomainEventPublisher
    private lateinit var commentService: CommentService

    private val currentUserId: UUID = UUID.randomUUID()
    private val postId: UUID = UUID.randomUUID()

    @Suppress("UNCHECKED_CAST")
    private fun <T> anyNonNull(): T {
        org.mockito.Mockito.any<T>()
        return null as T
    }

    @BeforeEach
    fun setUp() {
        commentRepository = mock(CommentRepository::class.java)
        postRepository = mock(PostRepository::class.java)
        profileRepository = mock(ProfileRepository::class.java)
        commentMapper = CommentMapper()
        currentUserProvider = mock(CurrentUserProvider::class.java)
        domainEventPublisher = mock(DomainEventPublisher::class.java)

        `when`(currentUserProvider.getCurrentUserId()).thenReturn(currentUserId)

        commentService = CommentService(
            commentRepository = commentRepository,
            postRepository = postRepository,
            profileRepository = profileRepository,
            commentMapper = commentMapper,
            currentUserProvider = currentUserProvider,
            domainEventPublisher = domainEventPublisher
        )
    }

    @Test
    fun `addComment creates comment and publishes event`() {
        val author = ProfileEntity(id = currentUserId, username = "somraj", email = "s@acadyk.com", fullName = "Somraj")
        val post = PostEntity(id = postId, author = author, content = "Main Post", commentsCount = 0)
        val request = AddCommentRequest(content = "Great platform!")

        `when`(postRepository.findByIdAndDeletedAtIsNull(postId)).thenReturn(Optional.of(post))
        `when`(profileRepository.findById(currentUserId)).thenReturn(Optional.of(author))
        `when`(commentRepository.save(anyNonNull())).thenAnswer { it.arguments[0] }

        val result = commentService.addComment(postId, request)

        assertNotNull(result)
        assertEquals("Great platform!", result.content)
        assertEquals(1, post.commentsCount)
        verify(postRepository, times(1)).save(post)
        verify(domainEventPublisher, times(1)).publishCommentCreated(anyNonNull())
    }

    @Test
    fun `deleteComment soft deletes comment and decrements post commentsCount`() {
        val author = ProfileEntity(id = currentUserId, username = "somraj", email = "s@acadyk.com", fullName = "Somraj")
        val post = PostEntity(id = postId, author = author, content = "Main Post", commentsCount = 1)
        val commentId = UUID.randomUUID()
        val comment = CommentEntity(id = commentId, post = post, author = author, content = "Nice post")

        `when`(commentRepository.findByIdAndDeletedAtIsNull(commentId)).thenReturn(Optional.of(comment))
        `when`(postRepository.findByIdAndDeletedAtIsNull(postId)).thenReturn(Optional.of(post))

        commentService.deleteComment(postId, commentId)

        assertNotNull(comment.deletedAt)
        assertEquals(0, post.commentsCount)
        verify(commentRepository, times(1)).save(comment)
        verify(postRepository, times(1)).save(post)
    }

    @Test
    fun `deleteComment throws ForbiddenException if user is not author`() {
        val author = ProfileEntity(id = UUID.randomUUID(), username = "other", email = "other@acadyk.com", fullName = "Other")
        val post = PostEntity(id = postId, author = author, content = "Main Post")
        val commentId = UUID.randomUUID()
        val comment = CommentEntity(id = commentId, post = post, author = author, content = "Nice post")

        `when`(commentRepository.findByIdAndDeletedAtIsNull(commentId)).thenReturn(Optional.of(comment))

        assertThrows<ForbiddenException> {
            commentService.deleteComment(postId, commentId)
        }
    }
}
