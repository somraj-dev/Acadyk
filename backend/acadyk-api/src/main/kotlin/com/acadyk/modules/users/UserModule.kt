package com.acadyk.modules.users

import com.acadyk.common.ApiResponse
import com.acadyk.common.ResourceNotFoundException
import com.acadyk.modules.profiles.dto.ProfileResponse
import com.acadyk.modules.profiles.mapper.ProfileMapper
import com.acadyk.modules.profiles.repository.ProfileRepository
import com.acadyk.modules.users.repository.UserRepository
import com.acadyk.security.CurrentUserProvider
import org.springframework.http.ResponseEntity
import org.springframework.stereotype.Service
import org.springframework.web.bind.annotation.*

import com.acadyk.common.PageResponse
import com.acadyk.common.toUUID
import com.acadyk.modules.profiles.service.ProfileService

data class UserIdentityResponse(
    val userId: String,
    val firebaseUid: String,
    val collegeEmail: String?,
    val enrollmentNumber: String?,
    val degree: String,
    val branch: String?,
    val joiningYear: Int?,
    val accountStatus: String,
    val profileCompleted: Boolean,
    val profile: ProfileResponse
)

@Service
class UserService(
    private val userRepository: UserRepository,
    private val profileRepository: ProfileRepository,
    private val profileService: ProfileService,
    private val profileMapper: ProfileMapper,
    private val currentUserProvider: CurrentUserProvider
) {
    fun getCurrentUserProfile(): ProfileResponse {
        val currentUserId = currentUserProvider.getCurrentUserId()
        return profileService.getProfileById(currentUserId)
    }

    fun getUserById(userId: String): ProfileResponse {
        return profileService.getProfileById(userId.toUUID())
    }

    fun searchUsers(query: String, page: Int, size: Int): PageResponse<ProfileResponse> {
        return profileService.searchProfiles(query.trim(), page, size)
    }

    fun getCurrentUserIdentity(): UserIdentityResponse {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val user = userRepository.findById(currentUserId)
            .or { userRepository.findByFirebaseUid(currentUserId.toString()) }
            .orElseThrow { ResourceNotFoundException("User identity not found") }

        val profile = profileService.getProfileById(user.id)

        return UserIdentityResponse(
            userId = user.id.toString(),
            firebaseUid = user.firebaseUid,
            collegeEmail = user.collegeEmail ?: user.email,
            enrollmentNumber = user.enrollmentNumber ?: profile.username,
            degree = user.degree,
            branch = user.branch ?: profile.major,
            joiningYear = user.joiningYear,
            accountStatus = user.accountStatus.name,
            profileCompleted = user.profileCompleted,
            profile = profile
        )
    }
}

@RestController
@RequestMapping("/api/v1/users")
class UserController(private val userService: UserService) {

    @GetMapping("/me")
    fun getMe(): ResponseEntity<ApiResponse<ProfileResponse>> {
        val profile = userService.getCurrentUserProfile()
        return ResponseEntity.ok(ApiResponse.success(profile))
    }

    @GetMapping("/identity")
    fun getIdentity(): ResponseEntity<ApiResponse<UserIdentityResponse>> {
        val identity = userService.getCurrentUserIdentity()
        return ResponseEntity.ok(ApiResponse.success(identity))
    }

    @GetMapping("/{userId}")
    fun getUserById(@PathVariable userId: String): ResponseEntity<ApiResponse<ProfileResponse>> {
        val profile = userService.getUserById(userId)
        return ResponseEntity.ok(ApiResponse.success(profile))
    }

    @GetMapping("/search")
    fun searchUsers(
        @RequestParam(name = "q", defaultValue = "") query: String,
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "20") size: Int
    ): ResponseEntity<ApiResponse<PageResponse<ProfileResponse>>> {
        val result = userService.searchUsers(query, page, size)
        return ResponseEntity.ok(ApiResponse.success(result))
    }
}
