package com.acadyk.unit

import com.acadyk.modules.posts.dto.CreatePostRequest
import com.acadyk.modules.posts.dto.PostResponse
import com.acadyk.modules.posts.entity.PostEntity
import com.acadyk.modules.posts.mapper.PostMapper
import com.acadyk.modules.posts.repository.PostMediaRepository
import com.acadyk.modules.posts.repository.PostRepository
import com.acadyk.modules.posts.service.PostService
import com.acadyk.modules.profiles.entity.ProfileEntity
import com.acadyk.modules.profiles.repository.ProfileRepository
import com.acadyk.infrastructure.kafka.DomainEventPublisher
import com.acadyk.infrastructure.redis.RedisCacheService
import com.acadyk.security.CurrentUserProvider
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.mockito.Mockito.*
import org.springframework.data.domain.PageImpl
import org.springframework.data.domain.PageRequest
import java.util.Optional
import java.util.UUID

class PostServiceTest {

    private lateinit var postRepository: PostRepository
    private lateinit var postMediaRepository: PostMediaRepository
    private lateinit var profileRepository: ProfileRepository
    private lateinit var postMapper: PostMapper
    private lateinit var currentUserProvider: CurrentUserProvider
    private lateinit var domainEventPublisher: DomainEventPublisher
    private lateinit var redisCacheService: RedisCacheService
    private lateinit var postService: PostService

    private val testUserId = UUID.randomUUID().toString()

    @BeforeEach
    fun setUp() {
        postRepository = mock(PostRepository::class.java)
        postMediaRepository = mock(PostMediaRepository::class.java)
        profileRepository = mock(ProfileRepository::class.java)
        postMapper = mock(PostMapper::class.java)
        currentUserProvider = mock(CurrentUserProvider::class.java)
        domainEventPublisher = mock(DomainEventPublisher::class.java)
        redisCacheService = mock(RedisCacheService::class.java)

        `when`(currentUserProvider.getCurrentUserId()).thenReturn(testUserId)

        postService = PostService(
            postRepository = postRepository,
            postMediaRepository = postMediaRepository,
            profileRepository = profileRepository,
            postMapper = postMapper,
            currentUserProvider = currentUserProvider,
            domainEventPublisher = domainEventPublisher,
            redisCacheService = redisCacheService
        )
    }

    @Test
    fun `createPost persists entity, clears cache, and publishes Kafka event`() {
        val request = CreatePostRequest(
            content = "Building an enterprise system with Kotlin, Spring Boot, and Flutter!",
            postType = "text"
        )

        val authorProfile = ProfileEntity(
            id = testUserId,
            email = "somraj@acadyk.com",
            fullName = "Somraj Lodhi"
        )

        val savedPost = PostEntity(
            id = UUID.randomUUID().toString(),
            author = authorProfile,
            content = request.content,
            postType = "text"
        )

        val responseDto = PostResponse(
            id = savedPost.id,
            authorId = authorProfile.id,
            authorName = authorProfile.fullName,
            content = savedPost.content,
            postType = savedPost.postType
        )

        `when`(profileRepository.findById(testUserId)).thenReturn(Optional.of(authorProfile))
        `when`(postRepository.save(any(PostEntity::class.java))).thenReturn(savedPost)
        `when`(postMapper.toResponse(eq(savedPost), anyList())).thenReturn(responseDto)

        val result = postService.createPost(request)

        assertNotNull(result)
        assertEquals(request.content, result.content)
        assertEquals(testUserId, result.authorId)
        verify(postRepository, times(1)).save(any())
        verify(redisCacheService, times(1)).evictPattern("feed:")
        verify(domainEventPublisher, times(1)).publishPostCreated(any())
    }

    @Test
    fun `getPosts returns paginated posts`() {
        val pageable = PageRequest.of(0, 10)
        val author = ProfileEntity(id = testUserId, email = "somraj@acadyk.com", fullName = "Somraj")
        val post = PostEntity(id = "p1", author = author, content = "Feed Item")

        `when`(postRepository.findAllByDeletedAtIsNullOrderByCreatedAtDesc(pageable))
            .thenReturn(PageImpl(listOf(post), pageable, 1))

        val result = postService.getPosts(0, 10)

        assertNotNull(result)
        assertEquals(1, result.content.size)
    }
}
