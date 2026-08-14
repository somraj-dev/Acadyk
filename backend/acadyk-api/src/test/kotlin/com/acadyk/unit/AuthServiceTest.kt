package com.acadyk.unit

import com.acadyk.modules.auth.*
import com.acadyk.modules.profiles.dto.ProfileResponse
import com.acadyk.modules.profiles.entity.ProfileEntity
import com.acadyk.modules.profiles.mapper.ProfileMapper
import com.acadyk.modules.profiles.repository.ProfileRepository
import com.acadyk.security.*
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.mockito.Mockito.*
import java.util.Optional
import java.util.UUID

class AuthServiceTest {

    private lateinit var profileRepository: ProfileRepository
    private lateinit var profileMapper: ProfileMapper
    private lateinit var tokenVerifier: FirebaseTokenVerifier
    private lateinit var currentUserProvider: CurrentUserProvider
    private lateinit var jwtTokenProvider: JwtTokenProvider
    private lateinit var auditService: AuditService
    private lateinit var authService: AuthService

    @BeforeEach
    fun setUp() {
        profileRepository = mock(ProfileRepository::class.java)
        profileMapper = mock(ProfileMapper::class.java)
        tokenVerifier = mock(FirebaseTokenVerifier::class.java)
        currentUserProvider = mock(CurrentUserProvider::class.java)
        jwtTokenProvider = mock(JwtTokenProvider::class.java)
        auditService = mock(AuditService::class.java)

        authService = AuthService(
            profileRepository = profileRepository,
            profileMapper = profileMapper,
            tokenVerifier = tokenVerifier,
            currentUserProvider = currentUserProvider,
            jwtTokenProvider = jwtTokenProvider,
            auditService = auditService
        )
    }

    @Test
    fun `register creates new user profile and returns JWT token`() {
        val request = RegisterRequest(
            email = "somraj@acadyk.com",
            password = "SecurePassword123!",
            fullName = "Somraj Lodhi"
        )

        val savedProfile = ProfileEntity(
            id = UUID.randomUUID().toString(),
            email = request.email,
            username = "somraj_dev",
            fullName = request.fullName
        )

        val profileResponse = ProfileResponse(
            id = savedProfile.id,
            email = savedProfile.email,
            username = savedProfile.username,
            fullName = savedProfile.fullName
        )

        `when`(profileRepository.save(any(ProfileEntity::class.java))).thenReturn(savedProfile)
        `when`(jwtTokenProvider.createToken(anyString(), anyString(), anyString())).thenReturn("mock_jwt_token")
        `when`(profileMapper.toResponse(savedProfile)).thenReturn(profileResponse)

        val response = authService.register(request, "127.0.0.1")

        assertNotNull(response)
        assertEquals("mock_jwt_token", response.token)
        assertEquals(request.email, response.user.email)
        verify(profileRepository, times(1)).save(any())
        verify(auditService, times(1)).logAuthEvent(eq("REGISTER_USER"), anyString(), eq(request.email), eq("127.0.0.1"), eq(true))
    }

    @Test
    fun `login returns auth response with token`() {
        val request = LoginRequest(
            email = "somraj@acadyk.com",
            password = "SecurePassword123!"
        )

        val existingProfile = ProfileEntity(
            id = UUID.randomUUID().toString(),
            email = request.email,
            username = "somraj_dev",
            fullName = "Somraj Lodhi"
        )

        val profileResponse = ProfileResponse(
            id = existingProfile.id,
            email = existingProfile.email,
            username = existingProfile.username,
            fullName = existingProfile.fullName
        )

        `when`(profileRepository.findByEmail(request.email)).thenReturn(Optional.of(existingProfile))
        `when`(jwtTokenProvider.createToken(anyString(), anyString(), anyString())).thenReturn("mock_login_jwt")
        `when`(profileMapper.toResponse(existingProfile)).thenReturn(profileResponse)

        val response = authService.login(request, "127.0.0.1")

        assertNotNull(response)
        assertEquals("mock_login_jwt", response.token)
        assertEquals(existingProfile.email, response.user.email)
        verify(auditService, times(1)).logAuthEvent(eq("EMAIL_PASSWORD_LOGIN"), anyString(), eq(request.email), eq("127.0.0.1"), eq(true))
    }
}
