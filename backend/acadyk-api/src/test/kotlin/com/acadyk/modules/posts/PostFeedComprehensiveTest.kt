package com.acadyk.modules.posts

import com.acadyk.common.ForbiddenException
import com.acadyk.infrastructure.kafka.DomainEventPublisher
import com.acadyk.infrastructure.redis.RedisCacheService
import com.acadyk.modules.posts.dto.CreatePostRequest
import com.acadyk.modules.posts.dto.UpdatePostRequest
import com.acadyk.modules.posts.entity.PostEntity
import com.acadyk.modules.posts.mapper.PostMapper
import com.acadyk.modules.posts.repository.PostMediaRepository
import com.acadyk.modules.posts.repository.PostRepository
import com.acadyk.modules.posts.service.PostService
import com.acadyk.modules.profiles.entity.ProfileEntity
import com.acadyk.modules.profiles.repository.ProfileRepository
import com.acadyk.modules.reactions.repository.PostReactionRepository
import com.acadyk.security.CurrentUserProvider
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import org.mockito.Mockito
import org.mockito.Mockito.*
import org.springframework.data.domain.PageImpl
import org.springframework.data.domain.PageRequest
import java.util.Optional
import java.util.UUID

class PostFeedComprehensiveTest {

    private lateinit var postRepository: PostRepository
    private lateinit var postMediaRepository: PostMediaRepository
    private lateinit var postReactionRepository: PostReactionRepository
    private lateinit var profileRepository: ProfileRepository
    private lateinit var postMapper: PostMapper
    private lateinit var currentUserProvider: CurrentUserProvider
    private lateinit var domainEventPublisher: DomainEventPublisher
    private lateinit var redisCacheService: RedisCacheService
    private lateinit var postService: PostService

    private val abhayUserId: UUID = UUID.fromString("11111111-1111-1111-1111-111111111111")
    private val rahulUserId: UUID = UUID.fromString("22222222-2222-2222-2222-222222222222")

    private val abhayProfile = ProfileEntity(
        id = abhayUserId,
        username = "abhay",
        fullName = "Abhay Chandel",
        email = "25am1ab4@mitsgwl.ac.in"
    )

    private val rahulProfile = ProfileEntity(
        id = rahulUserId,
        username = "rahul",
        fullName = "Rahul Sharma",
        email = "22cs1001@mitsgwl.ac.in"
    )

    @Suppress("UNCHECKED_CAST")
    private fun <T> anyNonNull(): T {
        Mockito.any<T>()
        return null as T
    }

    @BeforeEach
    fun setUp() {
        postRepository = mock(PostRepository::class.java)
        postMediaRepository = mock(PostMediaRepository::class.java)
        postReactionRepository = mock(PostReactionRepository::class.java)
        profileRepository = mock(ProfileRepository::class.java)
        postMapper = PostMapper()
        currentUserProvider = mock(CurrentUserProvider::class.java)
        domainEventPublisher = mock(DomainEventPublisher::class.java)
        redisCacheService = mock(RedisCacheService::class.java)

        `when`(currentUserProvider.getCurrentUserId()).thenReturn(abhayUserId)
        `when`(profileRepository.findById(abhayUserId)).thenReturn(Optional.of(abhayProfile))
        `when`(profileRepository.findById(rahulUserId)).thenReturn(Optional.of(rahulProfile))

        postService = PostService(
            postRepository = postRepository,
            postMediaRepository = postMediaRepository,
            postReactionRepository = postReactionRepository,
            profileRepository = profileRepository,
            postMapper = postMapper,
            currentUserProvider = currentUserProvider,
            domainEventPublisher = domainEventPublisher,
            redisCacheService = redisCacheService
        )
    }

    @Test
    fun `Abhay creates post - author is derived from verified security context and saved to database`() {
        val request = CreatePostRequest(
            content = "Testing real PostgreSQL database-backed feed in Acadyk!",
            postType = "text",
            visibility = "PUBLIC"
        )

        val savedEntity = PostEntity(
            id = UUID.randomUUID(),
            author = abhayProfile,
            content = request.content,
            postType = "text",
            visibility = "PUBLIC",
            likesCount = 0,
            commentsCount = 0
        )

        `when`(postRepository.save(anyNonNull())).thenReturn(savedEntity)

        val response = postService.createPost(request)

        assertNotNull(response)
        assertEquals(request.content, response.content)
        assertEquals(abhayUserId.toString(), response.author.id)
        assertEquals("Abhay Chandel", response.author.fullName)
        assertEquals("abhay", response.author.username)
        assertEquals("25am1ab4@mitsgwl.ac.in", response.author.email)

        verify(postRepository, times(1)).save(anyNonNull())
        verify(redisCacheService, times(1)).evictPattern("feed:")
        verify(domainEventPublisher, times(1)).publishPostCreated(anyNonNull())
    }

    @Test
    fun `Empty database feed returns empty page without falling back to mock or demo data`() {
        val pageable = PageRequest.of(0, 10)
        `when`(postRepository.findAllByDeletedAtIsNullOrderByCreatedAtDesc(pageable))
            .thenReturn(PageImpl(emptyList(), pageable, 0))

        val result = postService.getPosts(0, 10)

        assertNotNull(result)
        assertTrue(result.content.isEmpty())
        assertEquals(0, result.totalElements)
        assertEquals(0, result.totalPages)
    }

    @Test
    fun `Feed retrieves real database posts with isLiked calculated for authenticated user`() {
        val pageable = PageRequest.of(0, 10)
        val postId = UUID.randomUUID()
        val post = PostEntity(
            id = postId,
            author = abhayProfile,
            content = "Real post in database",
            likesCount = 1,
            commentsCount = 0
        )

        `when`(postRepository.findAllByDeletedAtIsNullOrderByCreatedAtDesc(pageable))
            .thenReturn(PageImpl(listOf(post), pageable, 1))
        `when`(postReactionRepository.existsByPostIdAndUserId(postId, abhayUserId))
            .thenReturn(true)

        val result = postService.getPosts(0, 10)

        assertEquals(1, result.content.size)
        val postResponse = result.content[0]
        assertEquals(postId.toString(), postResponse.id)
        assertEquals("Abhay Chandel", postResponse.author.fullName)
        assertEquals("25am1ab4@mitsgwl.ac.in", postResponse.author.email)
        assertTrue(postResponse.isLiked)
        assertEquals(1, postResponse.likesCount)
    }

    @Test
    fun `Another user (Rahul) cannot edit or delete Abhay's post`() {
        val postId = UUID.randomUUID()
        val post = PostEntity(
            id = postId,
            author = abhayProfile,
            content = "Abhay's exclusive post"
        )

        `when`(postRepository.findByIdAndDeletedAtIsNull(postId)).thenReturn(Optional.of(post))

        // Switch authenticated user to Rahul
        `when`(currentUserProvider.getCurrentUserId()).thenReturn(rahulUserId)

        assertThrows<ForbiddenException> {
            postService.updatePost(postId, UpdatePostRequest(content = "Rahul trying to edit"))
        }

        assertThrows<ForbiddenException> {
            postService.deletePost(postId)
        }

        verify(postRepository, never()).save(anyNonNull())
    }

    @Test
    fun `Abhay can update his own post and cache is evicted`() {
        val postId = UUID.randomUUID()
        val post = PostEntity(
            id = postId,
            author = abhayProfile,
            content = "Original text"
        )

        `when`(postRepository.findByIdAndDeletedAtIsNull(postId)).thenReturn(Optional.of(post))
        `when`(postRepository.save(anyNonNull())).thenAnswer { it.arguments[0] }

        val updated = postService.updatePost(postId, UpdatePostRequest(content = "Edited real text"))

        assertEquals("Edited real text", updated.content)
        verify(postRepository, times(1)).save(post)
        verify(redisCacheService, times(1)).evictPattern("feed:")
    }

    @Test
    fun `Cross-user feed visibility - Rahul retrieves Abhay's canonical posts with proper author info and reaction states`() {
        val pageable = PageRequest.of(0, 20)
        val postId1 = UUID.fromString("c3333333-3333-3333-3333-333333333301")
        val postId2 = UUID.fromString("c3333333-3333-3333-3333-333333333302")

        val post1 = PostEntity(
            id = postId1,
            author = abhayProfile,
            content = "AI is moving incredibly fast. The interesting part isn't just generating code anymore — it's understanding how to verify, test, and actually use what AI produces.",
            likesCount = 3,
            commentsCount = 1
        )
        val post2 = PostEntity(
            id = postId2,
            author = abhayProfile,
            content = "Working on a few ideas around campus technology and student collaboration.",
            likesCount = 5,
            commentsCount = 0
        )

        `when`(postRepository.findAllByDeletedAtIsNullOrderByCreatedAtDesc(pageable))
            .thenReturn(PageImpl(listOf(post1, post2), pageable, 2))

        // Authenticated user is Rahul
        `when`(currentUserProvider.getCurrentUserId()).thenReturn(rahulUserId)
        `when`(postReactionRepository.existsByPostIdAndUserId(postId1, rahulUserId)).thenReturn(true)
        `when`(postReactionRepository.existsByPostIdAndUserId(postId2, rahulUserId)).thenReturn(false)

        val feed = postService.getPosts(0, 20)

        assertNotNull(feed)
        assertEquals(2, feed.content.size)

        val item1 = feed.content[0]
        assertEquals(postId1.toString(), item1.id)
        assertEquals(abhayUserId.toString(), item1.author.id)
        assertEquals("Abhay Chandel", item1.author.fullName)
        assertEquals("25am1ab4@mitsgwl.ac.in", item1.author.email)
        assertTrue(item1.isLiked, "Rahul liked post 1")
        assertEquals(3, item1.likesCount)
        assertEquals(1, item1.commentsCount)

        val item2 = feed.content[1]
        assertEquals(postId2.toString(), item2.id)
        assertEquals(abhayUserId.toString(), item2.author.id)
        assertFalse(item2.isLiked, "Rahul has not liked post 2")
        assertEquals(5, item2.likesCount)
    }
}

