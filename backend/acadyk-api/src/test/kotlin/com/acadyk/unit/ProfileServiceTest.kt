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

class ProfileServiceTest {

    private lateinit var profileRepository: ProfileRepository
    private lateinit var educationRepository: EducationRepository
    private lateinit var experienceRepository: ExperienceRepository
    private lateinit var certificateRepository: CertificateRepository
    private lateinit var resumeRepository: ResumeRepository
    private lateinit var profileMapper: ProfileMapper
    private lateinit var currentUserProvider: CurrentUserProvider
    private lateinit var profileService: ProfileService

    private val testUserId = UUID.randomUUID().toString()

    @Suppress("UNCHECKED_CAST")
    private fun <T> anyNonNull(): T {
        Mockito.any<T>()
        return null as T
    }

    @BeforeEach
    fun setUp() {
        profileRepository = mock(ProfileRepository::class.java)
        educationRepository = mock(EducationRepository::class.java)
        experienceRepository = mock(ExperienceRepository::class.java)
        certificateRepository = mock(CertificateRepository::class.java)
        resumeRepository = mock(ResumeRepository::class.java)
        profileMapper = ProfileMapper()
        currentUserProvider = mock(CurrentUserProvider::class.java)

        `when`(currentUserProvider.getCurrentUserId()).thenReturn(testUserId)
        `when`(currentUserProvider.getCurrentUserEmail()).thenReturn("somraj@acadyk.com")

        profileService = ProfileService(
            profileRepository = profileRepository,
            educationRepository = educationRepository,
            experienceRepository = experienceRepository,
            certificateRepository = certificateRepository,
            resumeRepository = resumeRepository,
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
}
