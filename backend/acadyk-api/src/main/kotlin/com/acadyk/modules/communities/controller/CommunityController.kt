package com.acadyk.modules.communities.controller

import com.acadyk.common.ApiResponse
import com.acadyk.common.PageResponse
import com.acadyk.modules.communities.dto.CommunityResponse
import com.acadyk.modules.communities.dto.CreateCommunityRequest
import com.acadyk.modules.communities.service.CommunityService
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/v1/communities")
@CrossOrigin(origins = ["*"])
class CommunityController(private val communityService: CommunityService) {

    @GetMapping
    fun getCommunities(
        @RequestParam(required = false) category: String?,
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "20") size: Int
    ): ResponseEntity<ApiResponse<PageResponse<CommunityResponse>>> {
        val result = communityService.getCommunities(category, page, size)
        return ResponseEntity.ok(ApiResponse.success(result))
    }

    @GetMapping("/{id}")
    fun getCommunityById(@PathVariable id: String): ResponseEntity<ApiResponse<CommunityResponse>> {
        val result = communityService.getCommunityById(id)
        return ResponseEntity.ok(ApiResponse.success(result))
    }

    @PostMapping
    fun createCommunity(@Valid @RequestBody request: CreateCommunityRequest): ResponseEntity<ApiResponse<CommunityResponse>> {
        val result = communityService.createCommunity(request)
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(ApiResponse.success(result, "Community created successfully"))
    }

    @PostMapping("/{id}/join")
    fun toggleJoin(@PathVariable id: String): ResponseEntity<ApiResponse<Map<String, Boolean>>> {
        val isMember = communityService.toggleMembership(id)
        return ResponseEntity.ok(ApiResponse.success(mapOf("isMember" to isMember)))
    }
}
