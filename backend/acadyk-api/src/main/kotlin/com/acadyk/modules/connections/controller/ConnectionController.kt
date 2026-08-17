package com.acadyk.modules.connections.controller

import com.acadyk.common.ApiResponse
import com.acadyk.modules.connections.dto.ConnectionRequestResponse
import com.acadyk.modules.connections.dto.FollowStatusResponse
import com.acadyk.modules.connections.dto.SendConnectionRequest
import com.acadyk.modules.connections.service.ConnectionService
import com.acadyk.modules.profiles.dto.ProfileResponse
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/v1")
@CrossOrigin(origins = ["*"])
class ConnectionController(private val connectionService: ConnectionService) {

    @PostMapping("/connections/requests")
    fun sendRequest(@Valid @RequestBody request: SendConnectionRequest): ResponseEntity<ApiResponse<ConnectionRequestResponse>> {
        val result = connectionService.sendConnectionRequest(request)
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(ApiResponse.success(result, "Connection request sent"))
    }

    @PostMapping("/connections/{id}/accept")
    fun acceptRequest(@PathVariable id: String): ResponseEntity<ApiResponse<Unit>> {
        connectionService.acceptConnectionRequest(id)
        return ResponseEntity.ok(ApiResponse.success(Unit, "Connection accepted"))
    }

    @DeleteMapping("/connections/{id}")
    fun removeConnection(@PathVariable id: String): ResponseEntity<ApiResponse<Unit>> {
        connectionService.removeConnection(id)
        return ResponseEntity.ok(ApiResponse.success(Unit, "Connection removed"))
    }

    @PostMapping("/profiles/{userId}/follow")
    fun toggleFollow(@PathVariable userId: String): ResponseEntity<ApiResponse<FollowStatusResponse>> {
        val result = connectionService.toggleFollow(userId)
        return ResponseEntity.ok(ApiResponse.success(result))
    }

    @GetMapping("/profiles/{userId}/followers")
    fun getFollowers(@PathVariable userId: String): ResponseEntity<ApiResponse<List<ProfileResponse>>> {
        return ResponseEntity.ok(ApiResponse.success(connectionService.getFollowers(userId)))
    }

    @GetMapping("/profiles/{userId}/following")
    fun getFollowing(@PathVariable userId: String): ResponseEntity<ApiResponse<List<ProfileResponse>>> {
        return ResponseEntity.ok(ApiResponse.success(connectionService.getFollowing(userId)))
    }
}
