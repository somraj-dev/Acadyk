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
    private val profileMapper: ProfileMapper,
    private val currentUserProvider: CurrentUserProvider
) {
    fun getCurrentUserProfile(): ProfileResponse {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val profile = profileRepository.findById(currentUserId)
            .orElseThrow { ResourceNotFoundException("User profile not found") }
        return profileMapper.toResponse(profile)
    }

    fun getCurrentUserIdentity(): UserIdentityResponse {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val user = userRepository.findById(currentUserId)
            .or { userRepository.findByFirebaseUid(currentUserId) }
            .orElseThrow { ResourceNotFoundException("User identity not found") }

        val profile = profileRepository.findById(user.id)
            .orElseGet { profileRepository.findById(currentUserId).orElseThrow { ResourceNotFoundException("Profile not found") } }

        return UserIdentityResponse(
            userId = user.id,
            firebaseUid = user.firebaseUid,
            collegeEmail = user.collegeEmail ?: user.email,
            enrollmentNumber = user.enrollmentNumber ?: profile.username,
            degree = user.degree,
            branch = user.branch ?: profile.major,
            joiningYear = user.joiningYear,
            accountStatus = user.accountStatus.name,
            profileCompleted = user.profileCompleted,
            profile = profileMapper.toResponse(profile)
        )
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

    @GetMapping("/identity")
    fun getIdentity(): ResponseEntity<ApiResponse<UserIdentityResponse>> {
        val identity = userService.getCurrentUserIdentity()
        return ResponseEntity.ok(ApiResponse.success(identity))
    }
}
