package com.acadyk.unit

import com.acadyk.common.PageResponse
import com.acadyk.modules.profiles.dto.ProfileResponse
import com.acadyk.modules.profiles.mapper.ProfileMapper
import com.acadyk.modules.profiles.repository.ProfileRepository
import com.acadyk.modules.profiles.service.ProfileService
import com.acadyk.modules.users.UserService
import com.acadyk.modules.users.entity.AccountStatus
import com.acadyk.modules.users.entity.UserEntity
import com.acadyk.modules.users.repository.UserRepository
import com.acadyk.security.CurrentUserProvider
import com.acadyk.security.Role
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.mockito.Mockito.*
import org.springframework.data.domain.PageImpl
import java.util.Optional
import java.util.UUID

class UserServiceTest {

    private lateinit var userRepository: UserRepository
    private lateinit var profileRepository: ProfileRepository
    private lateinit var profileService: ProfileService
    private lateinit var profileMapper: ProfileMapper
    private lateinit var currentUserProvider: CurrentUserProvider
    private lateinit var userService: UserService

    private val testUserId: UUID = UUID.randomUUID()

    @BeforeEach
    fun setUp() {
        userRepository = mock(UserRepository::class.java)
        profileRepository = mock(ProfileRepository::class.java)
        profileService = mock(ProfileService::class.java)
        profileMapper = ProfileMapper()
        currentUserProvider = mock(CurrentUserProvider::class.java)

        `when`(currentUserProvider.getCurrentUserId()).thenReturn(testUserId)

        userService = UserService(
            userRepository = userRepository,
            profileRepository = profileRepository,
            profileService = profileService,
            profileMapper = profileMapper,
            currentUserProvider = currentUserProvider
        )
    }

    @Test
    fun `getCurrentUserProfile returns current user profile`() {
        val profileResponse = ProfileResponse(
            id = testUserId.toString(),
            username = "somraj",
            fullName = "Somraj Lodhi",
            email = "somraj@acadyk.com",
            headline = "Founder",
            bio = "Quant Engineer",
            collegeName = "MITS Gwalior",
            major = "AI & ML",
            graduationYear = 2029,
            location = "India",
            profilePhotoUrl = null,
            coverPhotoUrl = null,
            statusEmoji = null,
            statusText = null,
            isPrivate = false,
            followersCount = 10,
            followingCount = 5,
            connectionsCount = 2,
            postCount = 4,
            isFollowing = false,
            isFollowedBy = false
        )

        `when`(profileService.getProfileById(testUserId)).thenReturn(profileResponse)

        val result = userService.getCurrentUserProfile()

        assertNotNull(result)
        assertEquals("Somraj Lodhi", result.fullName)
        assertEquals(4, result.postCount)
    }

    @Test
    fun `getCurrentUserIdentity returns complete student identity info`() {
        val userEntity = UserEntity(
            id = testUserId,
            firebaseUid = "fb_12345",
            email = "25am10so80@mitsgwl.ac.in",
            collegeEmail = "25am10so80@mitsgwl.ac.in",
            enrollmentNumber = "BTAM25O1080",
            degree = "B.Tech",
            branch = "Artificial Intelligence and Machine Learning",
            joiningYear = 2025,
            accountStatus = AccountStatus.ACTIVE,
            role = Role.STUDENT
        )

        val profileResponse = ProfileResponse(
            id = testUserId.toString(),
            username = "BTAM25O1080",
            fullName = "Somraj Lodhi",
            email = "25am10so80@mitsgwl.ac.in",
            headline = null,
            bio = null,
            collegeName = "MITS Gwalior",
            major = "Artificial Intelligence and Machine Learning",
            graduationYear = 2029,
            location = "India",
            profilePhotoUrl = null,
            coverPhotoUrl = null,
            statusEmoji = null,
            statusText = null,
            isPrivate = false
        )

        `when`(userRepository.findById(testUserId)).thenReturn(Optional.of(userEntity))
        `when`(profileService.getProfileById(testUserId)).thenReturn(profileResponse)

        val identity = userService.getCurrentUserIdentity()

        assertNotNull(identity)
        assertEquals("BTAM25O1080", identity.enrollmentNumber)
        assertEquals("25am10so80@mitsgwl.ac.in", identity.collegeEmail)
        assertEquals("B.Tech", identity.degree)
        assertEquals("Artificial Intelligence and Machine Learning", identity.branch)
        assertEquals(2025, identity.joiningYear)
    }

    @Test
    fun `searchUsers delegates to profileService searchProfiles`() {
        val pageResponse = PageResponse(
            content = listOf(
                ProfileResponse(
                    id = testUserId.toString(),
                    username = "somraj",
                    fullName = "Somraj Lodhi",
                    email = "somraj@acadyk.com",
                    headline = null,
                    bio = null,
                    collegeName = "MITS Gwalior",
                    major = "AI",
                    graduationYear = 2029,
                    location = "India",
                    profilePhotoUrl = null,
                    coverPhotoUrl = null,
                    statusEmoji = null,
                    statusText = null,
                    isPrivate = false
                )
            ),
            pageNumber = 0,
            pageSize = 20,
            totalElements = 1,
            totalPages = 1,
            isLast = true
        )

        `when`(profileService.searchProfiles("Somraj", 0, 20)).thenReturn(pageResponse)

        val result = userService.searchUsers("Somraj", 0, 20)

        assertNotNull(result)
        assertEquals(1, result.content.size)
        assertEquals("Somraj Lodhi", result.content[0].fullName)
    }
}
