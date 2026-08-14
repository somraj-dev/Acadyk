package com.acadyk.modules.clubs.controller

import com.acadyk.common.ApiResponse
import com.acadyk.common.PageResponse
import com.acadyk.modules.clubs.dto.ClubResponse
import com.acadyk.modules.clubs.dto.CreateClubRequest
import com.acadyk.modules.clubs.service.ClubService
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/v1/clubs")
@CrossOrigin(origins = ["*"])
class ClubController(private val clubService: ClubService) {

    @GetMapping
    fun getClubs(
        @RequestParam(required = false) college: String?,
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "20") size: Int
    ): ResponseEntity<ApiResponse<PageResponse<ClubResponse>>> {
        val result = clubService.getClubs(college, page, size)
        return ResponseEntity.ok(ApiResponse.success(result))
    }

    @GetMapping("/{id}")
    fun getClubById(@PathVariable id: String): ResponseEntity<ApiResponse<ClubResponse>> {
        val result = clubService.getClubById(id)
        return ResponseEntity.ok(ApiResponse.success(result))
    }

    @PostMapping
    fun createClub(@Valid @RequestBody request: CreateClubRequest): ResponseEntity<ApiResponse<ClubResponse>> {
        val result = clubService.createClub(request)
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(ApiResponse.success(result, "Club registered successfully"))
    }

    @PostMapping("/{id}/join")
    fun toggleJoin(@PathVariable id: String): ResponseEntity<ApiResponse<Map<String, Boolean>>> {
        val isMember = clubService.toggleJoin(id)
        return ResponseEntity.ok(ApiResponse.success(mapOf("isMember" to isMember)))
    }
}
