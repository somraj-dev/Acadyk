package com.acadyk.unit

import com.acadyk.modules.auth.dto.LoginRequest
import com.acadyk.modules.auth.dto.SignUpRequest
import com.acadyk.modules.auth.service.AuthService
import com.acadyk.modules.users.entity.UserEntity
import com.acadyk.modules.users.repository.UserRepository
import com.acadyk.modules.profiles.repository.ProfileRepository
import com.acadyk.infrastructure.kafka.DomainEventPublisher
import com.acadyk.security.JwtTokenProvider
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.mockito.Mockito.*
import org.springframework.security.crypto.password.PasswordEncoder
import java.util.Optional
import java.util.UUID

class AuthServiceTest {

    private lateinit var userRepository: UserRepository
    private lateinit var profileRepository: ProfileRepository
    private lateinit var jwtTokenProvider: JwtTokenProvider
    private lateinit var passwordEncoder: PasswordEncoder
    private lateinit var domainEventPublisher: DomainEventPublisher
    private lateinit var authService: AuthService

    @BeforeEach
    fun setUp() {
        userRepository = mock(UserRepository::class.java)
        profileRepository = mock(ProfileRepository::class.java)
        jwtTokenProvider = mock(JwtTokenProvider::class.java)
        passwordEncoder = mock(PasswordEncoder::class.java)
        domainEventPublisher = mock(DomainEventPublisher::class.java)

        authService = AuthService(
            userRepository = userRepository,
            profileRepository = profileRepository,
            jwtTokenProvider = jwtTokenProvider,
            passwordEncoder = passwordEncoder,
            domainEventPublisher = domainEventPublisher
        )
    }

    @Test
    fun `signUp creates new user and returns valid token`() {
        val request = SignUpRequest(
            email = "somraj@acadyk.com",
            password = "SecurePassword123!",
            fullName = "Somraj Lodhi",
            username = "somraj_dev"
        )

        `when`(userRepository.existsByEmail(request.email)).thenReturn(false)
        `when`(userRepository.existsByUsername(request.username)).thenReturn(false)
        `when`(passwordEncoder.encode(request.password)).thenReturn("hashed_password")

        val savedUser = UserEntity(
            id = UUID.randomUUID(),
            email = request.email,
            passwordHash = "hashed_password",
            fullName = request.fullName,
            username = request.username
        )

        `when`(userRepository.save(any(UserEntity::class.java))).thenReturn(savedUser)
        `when`(jwtTokenProvider.generateToken(any(), any(), any())).thenReturn("mock_jwt_token")

        val response = authService.signUp(request)

        assertNotNull(response)
        assertEquals("mock_jwt_token", response.token)
        assertEquals(request.email, response.user.email)
        verify(userRepository, times(1)).save(any())
        verify(domainEventPublisher, times(1)).publish(any())
    }

    @Test
    fun `login with valid credentials returns auth response`() {
        val request = LoginRequest(
            email = "somraj@acadyk.com",
            password = "SecurePassword123!"
        )

        val existingUser = UserEntity(
            id = UUID.randomUUID(),
            email = request.email,
            passwordHash = "hashed_password",
            fullName = "Somraj Lodhi",
            username = "somraj_dev"
        )

        `when`(userRepository.findByEmail(request.email)).thenReturn(Optional.of(existingUser))
        `when`(passwordEncoder.matches(request.password, existingUser.passwordHash)).thenReturn(true)
        `when`(jwtTokenProvider.generateToken(any(), any(), any())).thenReturn("mock_login_jwt")

        val response = authService.login(request)

        assertNotNull(response)
        assertEquals("mock_login_jwt", response.token)
        assertEquals(existingUser.email, response.user.email)
    }
}
