package com.acadyk.modules.admin.controller

import com.acadyk.common.ApiResponse
import com.acadyk.modules.admin.dto.*
import com.acadyk.modules.admin.service.AdminUserService
import com.acadyk.security.Role
import com.acadyk.security.UserPrincipal
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/v1/admin/users")
@PreAuthorize("hasRole('SUPER_ADMIN') or hasRole('COLLEGE_ADMIN') or hasRole('MODERATOR')")
class AdminUserController(
    private val adminUserService: AdminUserService
) {

    @GetMapping
    fun getUsers(
        @RequestParam(required = false) search: String?,
        @RequestParam(required = false) role: Role?,
        @RequestParam(required = false) status: String?,
        @RequestParam(required = false) course: String?,
        @RequestParam(required = false) branch: String?,
        @RequestParam(required = false) department: String?,
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "100") size: Int
    ): ResponseEntity<ApiResponse<List<AdminUserResponse>>> {
        val users = adminUserService.getUsers(
            search = search,
            role = role,
            status = status,
            course = course,
            branch = branch,
            department = department,
            page = page,
            size = size
        )
        return ResponseEntity.ok(ApiResponse.success(users))
    }

    @GetMapping("/{id}")
    fun getUserById(@PathVariable id: String): ResponseEntity<ApiResponse<AdminUserResponse>> {
        val user = adminUserService.getUserById(id)
        return ResponseEntity.ok(ApiResponse.success(user))
    }

    @GetMapping("/enrollment/{enrollment}")
    fun getUserByEnrollment(@PathVariable enrollment: String): ResponseEntity<ApiResponse<AdminUserResponse>> {
        val user = adminUserService.getUserById(enrollment)
        return ResponseEntity.ok(ApiResponse.success(user))
    }

    @GetMapping("/employee/{employeeId}")
    fun getUserByEmployeeId(@PathVariable employeeId: String): ResponseEntity<ApiResponse<AdminUserResponse>> {
        val user = adminUserService.getUserById(employeeId)
        return ResponseEntity.ok(ApiResponse.success(user))
    }

    @PostMapping
    @PreAuthorize("hasRole('SUPER_ADMIN') or hasRole('COLLEGE_ADMIN')")
    fun createUser(
        @RequestBody request: CreateAdminUserRequest,
        @AuthenticationPrincipal principal: UserPrincipal?
    ): ResponseEntity<ApiResponse<AdminUserResponse>> {
        val adminEmail = principal?.email ?: "system_admin"
        val created = adminUserService.createUser(request, adminEmail)
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(ApiResponse.success(created, "User created successfully"))
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('SUPER_ADMIN') or hasRole('COLLEGE_ADMIN')")
    fun updateUser(
        @PathVariable id: String,
        @RequestBody request: UpdateAdminUserRequest,
        @AuthenticationPrincipal principal: UserPrincipal?
    ): ResponseEntity<ApiResponse<AdminUserResponse>> {
        val adminEmail = principal?.email ?: "system_admin"
        val updated = adminUserService.updateUser(id, request, adminEmail)
        return ResponseEntity.ok(ApiResponse.success(updated, "User updated successfully"))
    }

    @PatchMapping("/{id}/status")
    @PreAuthorize("hasRole('SUPER_ADMIN') or hasRole('COLLEGE_ADMIN')")
    fun updateUserStatus(
        @PathVariable id: String,
        @RequestBody request: UpdateUserStatusRequest,
        @AuthenticationPrincipal principal: UserPrincipal?
    ): ResponseEntity<ApiResponse<AdminUserResponse>> {
        val adminEmail = principal?.email ?: "system_admin"
        val updated = adminUserService.updateUserStatus(id, request, adminEmail)
        return ResponseEntity.ok(ApiResponse.success(updated, "User status updated successfully"))
    }

    @PatchMapping("/{id}/suspend")
    @PreAuthorize("hasRole('SUPER_ADMIN') or hasRole('COLLEGE_ADMIN')")
    fun suspendUser(
        @PathVariable id: String,
        @RequestBody(required = false) request: SuspendUserRequest?,
        @AuthenticationPrincipal principal: UserPrincipal?
    ): ResponseEntity<ApiResponse<AdminUserResponse>> {
        val adminEmail = principal?.email ?: "system_admin"
        val updated = adminUserService.suspendUser(id, request?.reason, adminEmail)
        return ResponseEntity.ok(ApiResponse.success(updated, "User suspended successfully"))
    }

    @PatchMapping("/{id}/restore")
    @PreAuthorize("hasRole('SUPER_ADMIN') or hasRole('COLLEGE_ADMIN')")
    fun restoreUser(
        @PathVariable id: String,
        @AuthenticationPrincipal principal: UserPrincipal?
    ): ResponseEntity<ApiResponse<AdminUserResponse>> {
        val adminEmail = principal?.email ?: "system_admin"
        val updated = adminUserService.restoreUser(id, adminEmail)
        return ResponseEntity.ok(ApiResponse.success(updated, "User restored successfully"))
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('SUPER_ADMIN') or hasRole('COLLEGE_ADMIN')")
    fun deleteUser(
        @PathVariable id: String,
        @AuthenticationPrincipal principal: UserPrincipal?
    ): ResponseEntity<ApiResponse<Unit>> {
        val adminEmail = principal?.email ?: "system_admin"
        adminUserService.deleteUser(id, adminEmail)
        return ResponseEntity.ok(ApiResponse.success(Unit, "User deleted successfully"))
    }
}
