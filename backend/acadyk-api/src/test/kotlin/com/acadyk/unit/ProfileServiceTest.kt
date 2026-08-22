package com.acadyk.unit

import com.acadyk.modules.profiles.dto.UpdateProfileRequest
import com.acadyk.modules.profiles.entity.ProfileEntity
import com.acadyk.modules.profiles.mapper.ProfileMapper
import com.acadyk.modules.profiles.repository.CertificateRepository
import com.acadyk.modules.profiles.repository.EducationRepository
import com.acadyk.modules.profiles.repository.ExperienceRepository
import com.acadyk.modules.profiles.repository.ProfileRepository
import com.acadyk.modules.profiles.repository.ResumeRepository
import com.acadyk.modules.profiles.service.ProfileService
import com.acadyk.security.CurrentUserProvider
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import org.mockito.Mockito.*
import java.util.Optional
import java.util.UUID

import com.acadyk.modules.connections.repository.FollowRepository
import com.acadyk.modules.posts.repository.PostRepository

class ProfileServiceTest {

    private lateinit var profileRepository: ProfileRepository
    private lateinit var userRepository: com.acadyk.modules.users.repository.UserRepository
    private lateinit var educationRepository: EducationRepository
    private lateinit var experienceRepository: ExperienceRepository
    private lateinit var certificateRepository: CertificateRepository
    private lateinit var resumeRepository: ResumeRepository
    private lateinit var postRepository: PostRepository
    private lateinit var followRepository: FollowRepository
    private lateinit var profileMapper: ProfileMapper
    private lateinit var currentUserProvider: CurrentUserProvider
    private lateinit var profileService: ProfileService

    private val testUserId: UUID = UUID.randomUUID()

    @Suppress("UNCHECKED_CAST")
    private fun <T> anyNonNull(): T {
        Mockito.any<T>()
        return null as T
    }

    @BeforeEach
    fun setUp() {
        profileRepository = mock(ProfileRepository::class.java)
        userRepository = mock(com.acadyk.modules.users.repository.UserRepository::class.java)
        educationRepository = mock(EducationRepository::class.java)
        experienceRepository = mock(ExperienceRepository::class.java)
        certificateRepository = mock(CertificateRepository::class.java)
        resumeRepository = mock(ResumeRepository::class.java)
        postRepository = mock(PostRepository::class.java)
        followRepository = mock(FollowRepository::class.java)
        profileMapper = ProfileMapper()
        currentUserProvider = mock(CurrentUserProvider::class.java)

        `when`(currentUserProvider.getCurrentUserId()).thenReturn(testUserId)
        `when`(currentUserProvider.getCurrentUserEmail()).thenReturn("somraj@acadyk.com")

        profileService = ProfileService(
            profileRepository = profileRepository,
            userRepository = userRepository,
            educationRepository = educationRepository,
            experienceRepository = experienceRepository,
            certificateRepository = certificateRepository,
            resumeRepository = resumeRepository,
            postRepository = postRepository,
            followRepository = followRepository,
            profileMapper = profileMapper,
            currentUserProvider = currentUserProvider
        )
    }

    @Test
    fun `updateMyProfile updates profile fields`() {
        val existingProfile = ProfileEntity(
            id = testUserId,
            username = "somraj",
            email = "somraj@acadyk.com",
            fullName = "Old Name",
            bio = "Old Bio",
            location = "Old City"
        )

        val request = UpdateProfileRequest(
            fullName = "Somraj Lodhi",
            bio = "Founder | Quant Engineer",
            location = "Bangalore, India"
        )

        `when`(profileRepository.findById(testUserId)).thenReturn(Optional.of(existingProfile))
        `when`(profileRepository.save(anyNonNull())).thenAnswer { it.arguments[0] }

        val updated = profileService.updateMyProfile(request)

        assertNotNull(updated)
        assertEquals("Somraj Lodhi", updated.fullName)
        assertEquals("Founder | Quant Engineer", updated.bio)
        assertEquals("Bangalore, India", updated.location)
        verify(profileRepository, times(1)).save(anyNonNull())
    }

    @Test
    fun `getProfileById returns profile DTO when profile exists`() {
        val profile = ProfileEntity(
            id = testUserId,
            username = "somraj",
            email = "somraj@acadyk.com",
            fullName = "Somraj Lodhi",
            bio = "Acadyk Creator",
            location = "India"
        )

        `when`(profileRepository.findByIdAndDeletedAtIsNull(testUserId)).thenReturn(Optional.of(profile))

        val result = profileService.getProfileById(testUserId)

        assertNotNull(result)
        assertEquals("Somraj Lodhi", result.fullName)
        assertEquals("Acadyk Creator", result.bio)
    }

    @Test
    fun `searchProfiles passes current user ID to repository to exclude current user`() {
        val targetProfile = ProfileEntity(
            id = UUID.randomUUID(),
            username = "yugmittal",
            email = "yug@mitsgwl.ac.in",
            fullName = "Yug Mittal"
        )
        val page = org.springframework.data.domain.PageImpl(listOf(targetProfile))

        `when`(profileRepository.searchProfilesMultiField(anyNonNull(), anyNonNull(), anyNonNull(), anyNonNull())).thenReturn(page)
        `when`(postRepository.countByAuthorIdAndDeletedAtIsNull(anyNonNull())).thenReturn(0L)

        val result = profileService.searchProfiles("yug", 0, 20)

        assertNotNull(result)
        assertEquals(1, result.content.size)
        assertEquals("Yug Mittal", result.content[0].fullName)
        verify(profileRepository, times(1)).searchProfilesMultiField(anyNonNull(), anyNonNull(), anyNonNull(), anyNonNull())
    }

    @Test
    fun `searchProfiles with blank query calls findAllDiscoverable with current user ID`() {
        val targetProfile = ProfileEntity(
            id = UUID.randomUUID(),
            username = "yugmittal",
            email = "yug@mitsgwl.ac.in",
            fullName = "Yug Mittal"
        )
        val page = org.springframework.data.domain.PageImpl(listOf(targetProfile))

        `when`(profileRepository.findAllDiscoverable(anyNonNull(), anyNonNull(), anyNonNull())).thenReturn(page)
        `when`(postRepository.countByAuthorIdAndDeletedAtIsNull(anyNonNull())).thenReturn(0L)

        val result = profileService.searchProfiles("  ", 0, 20)

        assertNotNull(result)
        assertEquals(1, result.content.size)
        verify(profileRepository, times(1)).findAllDiscoverable(anyNonNull(), anyNonNull(), anyNonNull())
    }
}
