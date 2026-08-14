package com.acadyk.unit

import com.acadyk.modules.posts.dto.CreatePostDto
import com.acadyk.modules.posts.entity.PostEntity
import com.acadyk.modules.posts.entity.PostType
import com.acadyk.modules.posts.repository.PostRepository
import com.acadyk.modules.posts.service.PostService
import com.acadyk.infrastructure.kafka.DomainEventPublisher
import com.acadyk.infrastructure.redis.RedisCacheService
import com.acadyk.security.CurrentUserProvider
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.mockito.Mockito.*
import org.springframework.data.domain.PageImpl
import org.springframework.data.domain.PageRequest
import java.util.UUID

class PostServiceTest {

    private lateinit var postRepository: PostRepository
    private lateinit var domainEventPublisher: DomainEventPublisher
    private lateinit var redisCacheService: RedisCacheService
    private lateinit var currentUserProvider: CurrentUserProvider
    private lateinit var postService: PostService

    private val testUserId = UUID.randomUUID()

    @BeforeEach
    fun setUp() {
        postRepository = mock(PostRepository::class.java)
        domainEventPublisher = mock(DomainEventPublisher::class.java)
        redisCacheService = mock(RedisCacheService::class.java)
        currentUserProvider = mock(CurrentUserProvider::class.java)

        `when`(currentUserProvider.getCurrentUserId()).thenReturn(testUserId)

        postService = PostService(
            postRepository = postRepository,
            domainEventPublisher = domainEventPublisher,
            redisCacheService = redisCacheService,
            currentUserProvider = currentUserProvider
        )
    }

    @Test
    fun `createPost persists entity, clears cache, and emits Kafka event`() {
        val dto = CreatePostDto(
            content = "Building an enterprise system with Kotlin, Spring Boot, and Flutter!",
            postType = "GENERAL",
            mediaUrls = listOf("https://s3.amazonaws.com/bucket/image.png")
        )

        val savedPost = PostEntity(
            id = UUID.randomUUID(),
            userId = testUserId,
            content = dto.content,
            postType = PostType.GENERAL,
            mediaUrls = dto.mediaUrls
        )

        `when`(postRepository.save(any(PostEntity::class.java))).thenReturn(savedPost)

        val result = postService.createPost(dto)

        assertNotNull(result)
        assertEquals(dto.content, result.content)
        assertEquals(testUserId.toString(), result.userId)
        verify(postRepository, times(1)).save(any())
        verify(redisCacheService, times(1)).evictPattern("feed:*")
        verify(domainEventPublisher, times(1)).publish(any())
    }

    @Test
    fun `getFeed returns paginated posts`() {
        val pageable = PageRequest.of(0, 10)
        val postsList = listOf(
            PostEntity(
                id = UUID.randomUUID(),
                userId = testUserId,
                content = "Test Feed Post 1",
                postType = PostType.GENERAL
            ),
            PostEntity(
                id = UUID.randomUUID(),
                userId = testUserId,
                content = "Test Feed Post 2",
                postType = PostType.IMAGE
            )
        )

        `when`(postRepository.findAllByOrderByCreatedAtDesc(pageable)).thenReturn(PageImpl(postsList, pageable, 2))

        val feedPage = postService.getFeed(pageable)

        assertNotNull(feedPage)
        assertEquals(2, feedPage.content.size)
        assertEquals("Test Feed Post 1", feedPage.content[0].content)
    }
}
