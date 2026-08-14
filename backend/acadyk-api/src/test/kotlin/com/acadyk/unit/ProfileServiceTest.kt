package com.acadyk.unit

import com.acadyk.modules.profiles.dto.UpdateProfileDto
import com.acadyk.modules.profiles.entity.ProfileEntity
import com.acadyk.modules.profiles.repository.ProfileRepository
import com.acadyk.modules.profiles.repository.EducationRepository
import com.acadyk.modules.profiles.repository.WorkExperienceRepository
import com.acadyk.modules.profiles.repository.CertificateRepository
import com.acadyk.modules.profiles.repository.ResumeRepository
import com.acadyk.modules.profiles.service.ProfileService
import com.acadyk.infrastructure.kafka.DomainEventPublisher
import com.acadyk.security.CurrentUserProvider
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.mockito.Mockito.*
import java.util.Optional
import java.util.UUID

class ProfileServiceTest {

    private lateinit var profileRepository: ProfileRepository
    private lateinit var educationRepository: EducationRepository
    private lateinit var workExperienceRepository: WorkExperienceRepository
    private lateinit var certificateRepository: CertificateRepository
    private lateinit var resumeRepository: ResumeRepository
    private lateinit var domainEventPublisher: DomainEventPublisher
    private lateinit var currentUserProvider: CurrentUserProvider
    private lateinit var profileService: ProfileService

    private val testUserId = UUID.randomUUID()

    @BeforeEach
    fun setUp() {
        profileRepository = mock(ProfileRepository::class.java)
        educationRepository = mock(EducationRepository::class.java)
        workExperienceRepository = mock(WorkExperienceRepository::class.java)
        certificateRepository = mock(CertificateRepository::class.java)
        resumeRepository = mock(ResumeRepository::class.java)
        domainEventPublisher = mock(DomainEventPublisher::class.java)
        currentUserProvider = mock(CurrentUserProvider::class.java)

        `when`(currentUserProvider.getCurrentUserId()).thenReturn(testUserId)

        profileService = ProfileService(
            profileRepository = profileRepository,
            educationRepository = educationRepository,
            workExperienceRepository = workExperienceRepository,
            certificateRepository = certificateRepository,
            resumeRepository = resumeRepository,
            domainEventPublisher = domainEventPublisher,
            currentUserProvider = currentUserProvider
        )
    }

    @Test
    fun `updateProfile updates profile fields and publishes ProfileUpdated event`() {
        val existingProfile = ProfileEntity(
            id = testUserId,
            fullName = "Old Name",
            bio = "Old Bio",
            location = "Old City"
        )

        val dto = UpdateProfileDto(
            fullName = "Somraj Lodhi",
            bio = "Founder | Quant Engineer",
            location = "Bangalore, India",
            website = "https://quantaforze.com"
        )

        `when`(profileRepository.findById(testUserId)).thenReturn(Optional.of(existingProfile))
        `when`(profileRepository.save(any(ProfileEntity::class.java))).thenAnswer { it.arguments[0] }

        val updated = profileService.updateProfile(dto)

        assertNotNull(updated)
        assertEquals("Somraj Lodhi", updated.fullName)
        assertEquals("Founder | Quant Engineer", updated.bio)
        assertEquals("Bangalore, India", updated.location)
        verify(profileRepository, times(1)).save(existingProfile)
        verify(domainEventPublisher, times(1)).publish(any())
    }

    @Test
    fun `getProfileById returns profile DTO when profile exists`() {
        val profile = ProfileEntity(
            id = testUserId,
            fullName = "Somraj Lodhi",
            bio = "Acadyk Creator",
            location = "India"
        )

        `when`(profileRepository.findById(testUserId)).thenReturn(Optional.of(profile))

        val result = profileService.getProfileById(testUserId.toString())

        assertNotNull(result)
        assertEquals("Somraj Lodhi", result.fullName)
        assertEquals("Acadyk Creator", result.bio)
    }
}
