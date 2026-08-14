package com.acadyk.modules.startups.controller

import com.acadyk.common.ApiResponse
import com.acadyk.common.PageResponse
import com.acadyk.modules.startups.dto.CreateStartupRequest
import com.acadyk.modules.startups.dto.StartupResponse
import com.acadyk.modules.startups.service.StartupService
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/v1/startups")
@CrossOrigin(origins = ["*"])
class StartupController(private val startupService: StartupService) {

    @GetMapping
    fun getStartups(
        @RequestParam(required = false) stage: String?,
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "20") size: Int
    ): ResponseEntity<ApiResponse<PageResponse<StartupResponse>>> {
        val result = startupService.getStartups(stage, page, size)
        return ResponseEntity.ok(ApiResponse.success(result))
    }

    @GetMapping("/{id}")
    fun getStartupById(@PathVariable id: String): ResponseEntity<ApiResponse<StartupResponse>> {
        val result = startupService.getStartupById(id)
        return ResponseEntity.ok(ApiResponse.success(result))
    }

    @PostMapping
    fun createStartup(@Valid @RequestBody request: CreateStartupRequest): ResponseEntity<ApiResponse<StartupResponse>> {
        val result = startupService.createStartup(request)
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(ApiResponse.success(result, "Startup registered successfully"))
    }
}
