package com.acadyk.modules.users

import com.acadyk.common.ApiResponse
import com.acadyk.common.ResourceNotFoundException
import com.acadyk.modules.profiles.dto.ProfileResponse
import com.acadyk.modules.profiles.mapper.ProfileMapper
import com.acadyk.modules.profiles.repository.ProfileRepository
import com.acadyk.security.CurrentUserProvider
import org.springframework.http.ResponseEntity
import org.springframework.stereotype.Service
import org.springframework.web.bind.annotation.*

@Service
class UserService(
    private val profileRepository: ProfileRepository,
    private val profileMapper: ProfileMapper,
    private val currentUserProvider: CurrentUserProvider
) {
    fun getCurrentUserProfile(): ProfileResponse {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val profile = profileRepository.findById(currentUserId)
            .orElseThrow { ResourceNotFoundException("User profile not found") }
        return profileMapper.toResponse(profile)
    }
}

@RestController
@RequestMapping("/api/v1/users")
@CrossOrigin(origins = ["*"])
class UserController(private val userService: UserService) {

    @GetMapping("/me")
    fun getMe(): ResponseEntity<ApiResponse<ProfileResponse>> {
        val profile = userService.getCurrentUserProfile()
        return ResponseEntity.ok(ApiResponse.success(profile))
    }
}
