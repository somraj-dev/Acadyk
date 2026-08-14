package com.acadyk.modules.posts.service

import com.acadyk.common.ForbiddenException
import com.acadyk.common.PageResponse
import com.acadyk.common.ResourceNotFoundException
import com.acadyk.infrastructure.kafka.DomainEventPublisher
import com.acadyk.infrastructure.kafka.PostCreatedEvent
import com.acadyk.infrastructure.redis.RedisCacheService
import com.acadyk.modules.posts.dto.CreatePostRequest
import com.acadyk.modules.posts.dto.PostResponse
import com.acadyk.modules.posts.entity.PostEntity
import com.acadyk.modules.posts.entity.PostMediaEntity
import com.acadyk.modules.posts.mapper.PostMapper
import com.acadyk.modules.posts.repository.PostMediaRepository
import com.acadyk.modules.posts.repository.PostRepository
import com.acadyk.modules.profiles.repository.ProfileRepository
import com.acadyk.security.CurrentUserProvider
import org.springframework.data.domain.PageRequest
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Duration
import java.time.Instant

@Service
@Transactional
class PostService(
    private val postRepository: PostRepository,
    private val postMediaRepository: PostMediaRepository,
    private val profileRepository: ProfileRepository,
    private val postMapper: PostMapper,
    private val currentUserProvider: CurrentUserProvider,
    private val domainEventPublisher: DomainEventPublisher,
    private val redisCacheService: RedisCacheService
) {

    @Transactional(readOnly = true)
    fun getPosts(page: Int, size: Int): PageResponse<PostResponse> {
        val pageable = PageRequest.of(page, size)
        val postsPage = postRepository.findAllByDeletedAtIsNullOrderByCreatedAtDesc(pageable)

        return PageResponse.from(postsPage) { post ->
            val media = postMediaRepository.findAllByPostIdOrderByPositionAsc(post.id)
            postMapper.toResponse(post, media)
        }
    }

    @Transactional(readOnly = true)
    fun getPostById(id: String): PostResponse {
        val post = postRepository.findByIdAndDeletedAtIsNull(id)
            .orElseThrow { ResourceNotFoundException("Post with id $id not found") }
        val media = postMediaRepository.findAllByPostIdOrderByPositionAsc(post.id)
        return postMapper.toResponse(post, media)
    }

    fun createPost(request: CreatePostRequest): PostResponse {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val author = profileRepository.findById(currentUserId)
            .orElseThrow { ResourceNotFoundException("User profile not found") }

        val post = PostEntity(
            author = author,
            content = request.content,
            postType = request.postType ?: "text",
            visibility = request.visibility ?: "public",
            imageUrl = request.imageUrl
        )
        val savedPost = postRepository.save(post)

        val savedMedia = mutableListOf<PostMediaEntity>()
        request.mediaUrls?.forEachIndexed { index, url ->
            val media = postMediaRepository.save(
                PostMediaEntity(postId = savedPost.id, mediaUrl = url, position = index)
            )
            savedMedia.add(media)
        }

        // Invalidate feed caches
        redisCacheService.evictPattern("feed:")

        // Asynchronous side effects dispatched over Kafka
        domainEventPublisher.publishPostCreated(
            PostCreatedEvent(
                postId = savedPost.id,
                authorId = author.id,
                contentSnippet = savedPost.content.take(100),
                postType = savedPost.postType
            )
        )

        return postMapper.toResponse(savedPost, savedMedia)
    }

    fun deletePost(id: String) {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val post = postRepository.findByIdAndDeletedAtIsNull(id)
            .orElseThrow { ResourceNotFoundException("Post with id $id not found") }

        if (post.author.id != currentUserId) {
            throw ForbiddenException("You do not have permission to delete this post")
        }

        post.deletedAt = Instant.now()
        postRepository.save(post)

        redisCacheService.evictPattern("feed:")
        redisCacheService.evict("posts:${post.id}")
    }
}
