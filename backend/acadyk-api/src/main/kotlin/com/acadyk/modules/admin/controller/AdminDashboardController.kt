package com.acadyk.modules.admin.controller

import com.acadyk.common.ApiResponse
import com.acadyk.modules.admin.dto.AdminDashboardStatsResponse
import com.acadyk.modules.admin.service.AdminUserService
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.web.bind.annotation.CrossOrigin
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/v1/admin/dashboard")
@PreAuthorize("hasRole('SUPER_ADMIN') or hasRole('COLLEGE_ADMIN') or hasRole('MODERATOR')")
class AdminDashboardController(
    private val adminUserService: AdminUserService
) {

    @GetMapping("/stats")
    fun getDashboardStats(): ResponseEntity<ApiResponse<AdminDashboardStatsResponse>> {
        val stats = adminUserService.getDashboardStats()
        return ResponseEntity.ok(ApiResponse.success(stats))
    }
}
