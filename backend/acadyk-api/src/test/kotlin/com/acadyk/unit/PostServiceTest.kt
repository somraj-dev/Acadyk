package com.acadyk.unit

import com.acadyk.infrastructure.kafka.DomainEventPublisher
import com.acadyk.infrastructure.redis.RedisCacheService
import com.acadyk.modules.posts.dto.CreatePostRequest
import com.acadyk.modules.posts.entity.PostEntity
import com.acadyk.modules.posts.mapper.PostMapper
import com.acadyk.modules.posts.repository.PostMediaRepository
import com.acadyk.modules.posts.repository.PostRepository
import com.acadyk.modules.posts.service.PostService
import com.acadyk.modules.profiles.entity.ProfileEntity
import com.acadyk.modules.profiles.repository.ProfileRepository
import com.acadyk.security.CurrentUserProvider
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.mockito.Mockito
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

    @Suppress("UNCHECKED_CAST")
    private fun <T> anyNonNull(): T {
        Mockito.any<T>()
        return null as T
    }

    @BeforeEach
    fun setUp() {
        postRepository = mock(PostRepository::class.java)
        postMediaRepository = mock(PostMediaRepository::class.java)
        profileRepository = mock(ProfileRepository::class.java)
        postMapper = PostMapper()
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
            username = "somraj",
            fullName = "Somraj Lodhi",
            email = "somraj@acadyk.com"
        )

        val savedPost = PostEntity(
            id = UUID.randomUUID().toString(),
            author = authorProfile,
            content = request.content,
            postType = "text"
        )

        `when`(profileRepository.findById(testUserId)).thenReturn(Optional.of(authorProfile))
        `when`(postRepository.save(anyNonNull())).thenReturn(savedPost)

        val result = postService.createPost(request)

        assertNotNull(result)
        assertEquals(request.content, result.content)
        assertEquals(testUserId, result.author.id)
        verify(postRepository, times(1)).save(anyNonNull())
        verify(redisCacheService, times(1)).evictPattern("feed:")
        verify(domainEventPublisher, times(1)).publishPostCreated(anyNonNull())
    }

    @Test
    fun `getPosts returns paginated posts`() {
        val pageable = PageRequest.of(0, 10)
        val author = ProfileEntity(id = testUserId, username = "somraj", email = "somraj@acadyk.com", fullName = "Somraj")
        val post = PostEntity(id = "p1", author = author, content = "Feed Item")

        `when`(postRepository.findAllByDeletedAtIsNullOrderByCreatedAtDesc(pageable))
            .thenReturn(PageImpl(listOf(post), pageable, 1))

        val result = postService.getPosts(0, 10)

        assertNotNull(result)
        assertEquals(1, result.content.size)
    }
}
