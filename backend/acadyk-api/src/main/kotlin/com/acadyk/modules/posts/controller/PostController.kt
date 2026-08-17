package com.acadyk.modules.posts.controller

import com.acadyk.common.ApiResponse
import com.acadyk.common.PageResponse
import com.acadyk.modules.posts.dto.CreatePostRequest
import com.acadyk.modules.posts.dto.PostResponse
import com.acadyk.modules.posts.service.PostService
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/v1/posts")
@CrossOrigin(origins = ["*"])
class PostController(private val postService: PostService) {

    @GetMapping
    fun getPosts(
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "20") size: Int
    ): ResponseEntity<ApiResponse<PageResponse<PostResponse>>> {
        val result = postService.getPosts(page, size)
        return ResponseEntity.ok(ApiResponse.success(result))
    }

    @GetMapping("/{id}")
    fun getPostById(@PathVariable id: String): ResponseEntity<ApiResponse<PostResponse>> {
        val post = postService.getPostById(id)
        return ResponseEntity.ok(ApiResponse.success(post))
    }

    @PostMapping
    fun createPost(@Valid @RequestBody request: CreatePostRequest): ResponseEntity<ApiResponse<PostResponse>> {
        val post = postService.createPost(request)
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(ApiResponse.success(post, "Post published successfully"))
    }

    @DeleteMapping("/{id}")
    fun deletePost(@PathVariable id: String): ResponseEntity<ApiResponse<Unit>> {
        postService.deletePost(id)
        return ResponseEntity.ok(ApiResponse.success(Unit, "Post deleted successfully"))
    }
}
