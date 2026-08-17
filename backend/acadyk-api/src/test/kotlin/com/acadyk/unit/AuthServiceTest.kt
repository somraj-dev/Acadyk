package com.acadyk.unit

import com.acadyk.modules.auth.*
import com.acadyk.modules.auth.service.EnrollmentNumberService
import com.acadyk.modules.auth.service.ParsedEnrollmentInfo
import com.acadyk.modules.profiles.entity.ProfileEntity
import com.acadyk.modules.profiles.mapper.ProfileMapper
import com.acadyk.modules.profiles.repository.ProfileRepository
import com.acadyk.modules.users.entity.UserEntity
import com.acadyk.modules.users.repository.AuthAuditLogRepository
import com.acadyk.modules.users.repository.UserRepository
import com.acadyk.security.*
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import org.mockito.Mockito.*
import java.util.Optional
import java.util.UUID

class AuthServiceTest {

    private lateinit var userRepository: UserRepository
    private lateinit var profileRepository: ProfileRepository
    private lateinit var profileMapper: ProfileMapper
    private lateinit var tokenVerifier: FirebaseTokenVerifier
    private lateinit var enrollmentNumberService: EnrollmentNumberService
    private lateinit var currentUserProvider: CurrentUserProvider
    private lateinit var jwtTokenProvider: JwtTokenProvider
    private lateinit var authAuditLogRepository: AuthAuditLogRepository
    private lateinit var auditService: AuditService
    private lateinit var authService: AuthService

    private val defaultParsedInfo = ParsedEnrollmentInfo(
        enrollmentNumber = "0901CS211001",
        degree = "B.Tech",
        branch = "Computer Science",
        branchCode = "CS",
        joiningYear = 2021,
        isValid = true
    )

    @Suppress("UNCHECKED_CAST")
    private fun <T> anyNonNull(): T {
        Mockito.any<T>()
        return null as T
    }

    @BeforeEach
    fun setUp() {
        userRepository = mock(UserRepository::class.java)
        profileRepository = mock(ProfileRepository::class.java)
        profileMapper = ProfileMapper()
        tokenVerifier = mock(FirebaseTokenVerifier::class.java)
        enrollmentNumberService = mock(EnrollmentNumberService::class.java)
        currentUserProvider = mock(CurrentUserProvider::class.java)
        jwtTokenProvider = mock(JwtTokenProvider::class.java)
        authAuditLogRepository = mock(AuthAuditLogRepository::class.java)
        auditService = AuditService(authAuditLogRepository)

        `when`(enrollmentNumberService.parseCollegeEmail(anyNonNull())).thenReturn(defaultParsedInfo)

        authService = AuthService(
            userRepository = userRepository,
            profileRepository = profileRepository,
            profileMapper = profileMapper,
            tokenVerifier = tokenVerifier,
            enrollmentNumberService = enrollmentNumberService,
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

        val savedUser = UserEntity(
            id = UUID.randomUUID(),
            firebaseUid = "firebase_123",
            email = request.email,
            enrollmentNumber = defaultParsedInfo.enrollmentNumber
        )

        val savedProfile = ProfileEntity(
            id = savedUser.id,
            email = request.email,
            username = defaultParsedInfo.enrollmentNumber,
            fullName = request.fullName ?: "Somraj Lodhi"
        )

        `when`(userRepository.save(anyNonNull())).thenReturn(savedUser)
        `when`(profileRepository.save(anyNonNull())).thenReturn(savedProfile)
        `when`(jwtTokenProvider.createToken(anyNonNull<UUID>(), anyNonNull(), anyNonNull())).thenReturn("mock_jwt_token")

        val response = authService.register(request, "127.0.0.1")

        assertNotNull(response)
        assertEquals("mock_jwt_token", response.token)
        assertEquals(request.email, response.user.email)
        verify(profileRepository, times(1)).save(anyNonNull())
        verify(authAuditLogRepository, times(1)).save(anyNonNull())
    }

    @Test
    fun `login returns auth response with token`() {
        val request = LoginRequest(
            email = "somraj@acadyk.com",
            password = "SecurePassword123!"
        )

        val existingUser = UserEntity(
            id = UUID.randomUUID(),
            firebaseUid = "firebase_456",
            email = request.email,
            enrollmentNumber = "0901CS211001"
        )

        val existingProfile = ProfileEntity(
            id = existingUser.id,
            email = request.email,
            username = "0901CS211001",
            fullName = "Somraj Lodhi"
        )

        `when`(userRepository.findByEmail(request.email)).thenReturn(Optional.of(existingUser))
        `when`(profileRepository.findById(existingUser.id)).thenReturn(Optional.of(existingProfile))
        `when`(jwtTokenProvider.createToken(anyNonNull<UUID>(), anyNonNull(), anyNonNull())).thenReturn("mock_login_jwt")

        val response = authService.login(request, "127.0.0.1")

        assertNotNull(response)
        assertEquals("mock_login_jwt", response.token)
        assertEquals(existingProfile.email, response.user.email)
        verify(authAuditLogRepository, times(1)).save(anyNonNull())
    }
}
