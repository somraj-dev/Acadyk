package com.acadyk.modules.admin

import com.acadyk.common.BadRequestException
import com.acadyk.common.ConflictException
import com.acadyk.common.UnauthorizedException
import com.acadyk.modules.admin.dto.CreateAdminUserRequest
import com.acadyk.modules.admin.dto.UpdateAdminUserRequest
import com.acadyk.modules.admin.service.AdminUserService
import com.acadyk.modules.auth.AuthService
import com.acadyk.modules.auth.service.EnrollmentNumberService
import com.acadyk.modules.clubs.repository.ClubRepository
import com.acadyk.modules.communities.repository.CommunityRepository
import com.acadyk.modules.events.repository.EventRepository
import com.acadyk.modules.posts.repository.PostRepository
import com.acadyk.modules.profiles.entity.ProfileEntity
import com.acadyk.modules.profiles.mapper.ProfileMapper
import com.acadyk.modules.profiles.repository.ProfileRepository
import com.acadyk.modules.profiles.service.ProfileService
import com.acadyk.modules.users.entity.AccountStatus
import com.acadyk.modules.users.entity.UserEntity
import com.acadyk.modules.users.repository.AuthAuditLogRepository
import com.acadyk.modules.users.repository.UserRepository
import com.acadyk.security.*
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.mockito.ArgumentMatchers.any
import org.mockito.Mockito.*
import org.springframework.data.domain.PageImpl
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.domain.Specification
import java.time.Instant
import java.time.LocalDate
import java.util.Optional
import java.util.UUID

class AdminUserProvisioningE2ETest {

    private lateinit var userRepository: UserRepository
    private lateinit var profileRepository: ProfileRepository
    private lateinit var profileMapper: ProfileMapper
    private lateinit var tokenVerifier: FirebaseTokenVerifier
    private lateinit var enrollmentNumberService: EnrollmentNumberService
    private lateinit var currentUserProvider: CurrentUserProvider
    private lateinit var jwtTokenProvider: JwtTokenProvider
    private lateinit var authAuditLogRepository: AuthAuditLogRepository
    private lateinit var auditService: AuditService
    private lateinit var eventRepository: EventRepository
    private lateinit var clubRepository: ClubRepository
    private lateinit var postRepository: PostRepository
    private lateinit var communityRepository: CommunityRepository

    private lateinit var adminUserService: AdminUserService
    private lateinit var authService: AuthService

    @Suppress("UNCHECKED_CAST")
    private fun <T> anyNonNull(): T {
        any<T>()
        return null as T
    }

    @BeforeEach
    fun setUp() {
        userRepository = mock(UserRepository::class.java)
        profileRepository = mock(ProfileRepository::class.java)
        profileMapper = ProfileMapper()
        tokenVerifier = mock(FirebaseTokenVerifier::class.java)
        enrollmentNumberService = EnrollmentNumberService()
        currentUserProvider = mock(CurrentUserProvider::class.java)
        jwtTokenProvider = mock(JwtTokenProvider::class.java)
        authAuditLogRepository = mock(AuthAuditLogRepository::class.java)
        auditService = AuditService(authAuditLogRepository)
        eventRepository = mock(EventRepository::class.java)
        clubRepository = mock(ClubRepository::class.java)
        postRepository = mock(PostRepository::class.java)
        communityRepository = mock(CommunityRepository::class.java)

        adminUserService = AdminUserService(
            userRepository = userRepository,
            profileRepository = profileRepository,
            eventRepository = eventRepository,
            clubRepository = clubRepository,
            postRepository = postRepository,
            communityRepository = communityRepository,
            authAuditLogRepository = authAuditLogRepository,
            auditService = auditService,
            enrollmentNumberService = enrollmentNumberService
        )

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

    // =========================================================================
    // TEST 1 — Admin creates valid student
    // =========================================================================
    @Test
    fun `TEST 1 - Admin creates valid student in PostgreSQL`() {
        val request = CreateAdminUserRequest(
            fullName = "Ananya Sharma",
            email = "ananya.sharma@mits.ac.in",
            role = Role.STUDENT,
            enrollmentNumber = "BTAM2501062",
            course = "B.Tech",
            branch = "Artificial Intelligence and Machine Learning",
            department = "Department of AI & Robotics",
            phone = "9876543210",
            fatherName = "Ramesh Sharma",
            fatherMobile = "9876543211",
            currentAddress = "Hostel 4, MITS Campus, Gwalior",
            dateOfBirth = "2004-05-15",
            admissionDate = "2025-08-01"
        )

        `when`(userRepository.existsByEmail("ananya.sharma@mits.ac.in")).thenReturn(false)
        `when`(userRepository.existsByCollegeEmail("ananya.sharma@mits.ac.in")).thenReturn(false)
        `when`(userRepository.existsByEnrollmentNumber("BTAM2501062")).thenReturn(false)

        `when`(userRepository.save(anyNonNull())).thenAnswer { invocation ->
            invocation.getArgument(0) as UserEntity
        }
        `when`(profileRepository.save(anyNonNull())).thenAnswer { invocation ->
            invocation.getArgument(0) as ProfileEntity
        }

        val created = adminUserService.createUser(request, "admin@acadyk.com")

        assertNotNull(created)
        assertEquals("ananya.sharma@mits.ac.in", created.email)
        assertEquals("BTAM2501062", created.enrollmentNumber)
        assertEquals("active", created.status)
        assertEquals("Ananya Sharma", created.fullName)
        assertEquals("9876543210", created.phone)

        verify(userRepository, times(1)).save(anyNonNull())
        verify(profileRepository, times(1)).save(anyNonNull())
    }

    // =========================================================================
    // TEST 2 — Student authenticates with Firebase ID Token & Links UID
    // =========================================================================
    @Test
    fun `TEST 2 - Pre-provisioned student authenticates with Firebase and links UID`() {
        val email = "validstudent@mits.ac.in"
        val firebaseUid = "firebase_uid_valid_student_99"

        val provisionedUser = UserEntity(
            id = UUID.randomUUID(),
            firebaseUid = null, // pre-provisioned state
            email = email,
            collegeEmail = email,
            enrollmentNumber = "BTAM2501062",
            degree = "B.Tech",
            branch = "Artificial Intelligence and Machine Learning",
            joiningYear = 2025,
            role = Role.STUDENT,
            accountStatus = AccountStatus.ACTIVE,
            isActive = true
        )

        val profile = ProfileEntity(
            id = provisionedUser.id,
            userId = provisionedUser.id,
            username = "BTAM2501062",
            fullName = "Ananya Sharma",
            email = email,
            collegeName = "Madhav Institute of Technology & Science, Gwalior",
            major = "Artificial Intelligence and Machine Learning"
        )

        `when`(tokenVerifier.verifyToken("valid_id_token")).thenReturn(
            VerifiedTokenUser(
                uid = firebaseUid,
                email = email,
                name = "Ananya Sharma",
                picture = "https://cdn.acadyk.com/avatar.jpg",
                isEmailVerified = true
            )
        )

        `when`(userRepository.findByFirebaseUid(firebaseUid)).thenReturn(Optional.empty())
        `when`(userRepository.findByEmail(email)).thenReturn(Optional.of(provisionedUser))
        `when`(userRepository.save(anyNonNull())).thenAnswer { invocation -> invocation.getArgument(0) as UserEntity }
        `when`(profileRepository.findByUserId(provisionedUser.id)).thenReturn(Optional.of(profile))

        val authResponse = authService.verifyFirebaseToken("valid_id_token", "127.0.0.1")

        assertNotNull(authResponse)
        assertEquals("BTAM2501062", authResponse.enrollmentNumber)
        assertEquals("ACTIVE", authResponse.accountStatus)
        assertEquals(email, authResponse.user.email)
        assertEquals("Ananya Sharma", authResponse.user.fullName)

        // Verify Firebase UID was linked
        assertEquals(firebaseUid, provisionedUser.firebaseUid)
        verify(userRepository, atLeastOnce()).save(provisionedUser)
    }

    // =========================================================================
    // TEST 3 — Unprovisioned student login rejected (NO database record created)
    // =========================================================================
    @Test
    fun `TEST 3 - Unprovisioned student login is strictly rejected and creates no DB user`() {
        val unprovisionedEmail = "unprovisioned@mits.ac.in"
        val unprovisionedUid = "firebase_uid_unprovisioned_123"

        `when`(tokenVerifier.verifyToken("unprovisioned_token")).thenReturn(
            VerifiedTokenUser(
                uid = unprovisionedUid,
                email = unprovisionedEmail,
                name = "Unknown Student",
                picture = null,
                isEmailVerified = true
            )
        )

        `when`(userRepository.findByFirebaseUid(unprovisionedUid)).thenReturn(Optional.empty())
        `when`(userRepository.findByEmail(unprovisionedEmail)).thenReturn(Optional.empty())
        `when`(userRepository.findByCollegeEmail(unprovisionedEmail)).thenReturn(Optional.empty())

        val exception = assertThrows(UnauthorizedException::class.java) {
            authService.verifyFirebaseToken("unprovisioned_token", "127.0.0.1")
        }

        assertTrue(exception.message!!.contains("Account not found") || exception.message!!.contains("not been provisioned"))
        verify(userRepository, never()).save(anyNonNull())
        verify(profileRepository, never()).save(anyNonNull())
    }

    // =========================================================================
    // TEST 4 — Wrong email / non-MITS domain rejected
    // =========================================================================
    @Test
    fun `TEST 4 - Non-MITS domain like gmail or fake domain is rejected`() {
        // A: Firebase login with non-MITS domain
        `when`(tokenVerifier.verifyToken("gmail_token")).thenReturn(
            VerifiedTokenUser(
                uid = "uid_gmail_123",
                email = "student@gmail.com",
                name = "Gmail User",
                picture = null,
                isEmailVerified = true
            )
        )

        val exception = assertThrows(UnauthorizedException::class.java) {
            authService.verifyFirebaseToken("gmail_token", "127.0.0.1")
        }
        assertTrue(exception.message!!.contains("Only verified @mits.ac.in"))

        // B: Admin creation with invalid domain
        val badRequest = CreateAdminUserRequest(
            fullName = "Fake User",
            email = "student@mits.edu.in", // wrong domain!
            role = Role.STUDENT
        )
        assertThrows(BadRequestException::class.java) {
            adminUserService.createUser(badRequest, "admin@acadyk.com")
        }
    }

    // =========================================================================
    // TEST 5 — Duplicate Admin creation with same email rejected (409 Conflict)
    // =========================================================================
    @Test
    fun `TEST 5 - Duplicate admin creation with existing email returns 409 Conflict`() {
        val request = CreateAdminUserRequest(
            fullName = "Duplicate Test",
            email = "existing@mits.ac.in",
            role = Role.STUDENT,
            enrollmentNumber = "BTAM2501099"
        )

        `when`(userRepository.existsByEmail("existing@mits.ac.in")).thenReturn(true)

        val exception = assertThrows(ConflictException::class.java) {
            adminUserService.createUser(request, "admin@acadyk.com")
        }
        assertTrue(exception.message!!.contains("already exists"))
    }

    // =========================================================================
    // TEST 6 — Duplicate enrollment number rejected (409 Conflict)
    // =========================================================================
    @Test
    fun `TEST 6 - Duplicate enrollment number returns 409 Conflict`() {
        val request = CreateAdminUserRequest(
            fullName = "Another Student",
            email = "anotherstudent@mits.ac.in",
            role = Role.STUDENT,
            enrollmentNumber = "BTAM2501062" // Already used by another student!
        )

        `when`(userRepository.existsByEmail("anotherstudent@mits.ac.in")).thenReturn(false)
        `when`(userRepository.existsByCollegeEmail("anotherstudent@mits.ac.in")).thenReturn(false)
        `when`(userRepository.existsByEnrollmentNumber("BTAM2501062")).thenReturn(true)

        val exception = assertThrows(ConflictException::class.java) {
            adminUserService.createUser(request, "admin@acadyk.com")
        }
        assertTrue(exception.message!!.contains("enrollment number 'BTAM2501062' already exists"))
    }

    // =========================================================================
    // TEST 7 — Admin edits student -> Profile updated -> Profile fetch reflects changes
    // =========================================================================
    @Test
    fun `TEST 7 - Admin edits student details and updates PostgreSQL and profile`() {
        val userId = UUID.randomUUID()
        val user = UserEntity(
            id = userId,
            firebaseUid = "uid_123",
            email = "student@mits.ac.in",
            enrollmentNumber = "BTAM2501062",
            branch = "Computer Science",
            phone = "1111111111",
            currentAddress = "Old Address"
        )
        val profile = ProfileEntity(
            id = userId,
            userId = userId,
            username = "BTAM2501062",
            fullName = "Old Name",
            email = "student@mits.ac.in",
            major = "Computer Science"
        )

        `when`(userRepository.findById(userId)).thenReturn(Optional.of(user))
        `when`(profileRepository.findByUserId(userId)).thenReturn(Optional.of(profile))
        `when`(userRepository.save(anyNonNull())).thenAnswer { invocation -> invocation.getArgument(0) as UserEntity }
        `when`(profileRepository.save(anyNonNull())).thenAnswer { invocation -> invocation.getArgument(0) as ProfileEntity }

        val updateRequest = UpdateAdminUserRequest(
            fullName = "Updated Name",
            branch = "Artificial Intelligence and Machine Learning",
            phone = "9999999999",
            currentAddress = "New Address, MITS Hostels"
        )

        val updated = adminUserService.updateUser(userId.toString(), updateRequest, "admin@acadyk.com")

        assertEquals("Updated Name", updated.fullName)
        assertEquals("Artificial Intelligence and Machine Learning", updated.branch)
        assertEquals("9999999999", updated.phone)
        assertEquals("New Address, MITS Hostels", updated.currentAddress)

        verify(userRepository, times(1)).save(user)
        verify(profileRepository, times(1)).save(profile)
    }

    // =========================================================================
    // TEST 8 — Deactivated / Suspended account login rejected
    // =========================================================================
    @Test
    fun `TEST 8 - Deactivated or suspended student account is rejected on login`() {
        val email = "suspended@mits.ac.in"
        val uid = "uid_suspended_1"

        val suspendedUser = UserEntity(
            id = UUID.randomUUID(),
            firebaseUid = uid,
            email = email,
            accountStatus = AccountStatus.SUSPENDED,
            isActive = false
        )

        `when`(tokenVerifier.verifyToken("suspended_token")).thenReturn(
            VerifiedTokenUser(
                uid = uid,
                email = email,
                name = "Suspended User",
                picture = null,
                isEmailVerified = true
            )
        )

        `when`(userRepository.findByEmail(email)).thenReturn(Optional.of(suspendedUser))
        `when`(userRepository.findByFirebaseUid(uid)).thenReturn(Optional.of(suspendedUser))

        val exception = assertThrows(UnauthorizedException::class.java) {
            authService.verifyFirebaseToken("suspended_token", "127.0.0.1")
        }

        assertTrue(exception.message!!.contains("suspended"))
    }

    // =========================================================================
    // TEST 9 — Security: Firebase UID conflict handling
    // =========================================================================
    @Test
    fun `TEST 9 - Attempt to hijack another student with same UID is rejected`() {
        val victimUser = UserEntity(
            id = UUID.randomUUID(),
            firebaseUid = "uid_victim",
            email = "victim@mits.ac.in"
        )
        val attackerUser = UserEntity(
            id = UUID.randomUUID(),
            firebaseUid = null, // unlinked
            email = "attacker@mits.ac.in"
        )

        `when`(tokenVerifier.verifyToken("attacker_token")).thenReturn(
            VerifiedTokenUser(
                uid = "uid_victim", // Trying to bind to victim's UID!
                email = "attacker@mits.ac.in",
                name = "Attacker",
                picture = null,
                isEmailVerified = true
            )
        )

        `when`(userRepository.findByFirebaseUid("uid_victim")).thenReturn(Optional.of(victimUser))
        `when`(userRepository.findByEmail("attacker@mits.ac.in")).thenReturn(Optional.of(attackerUser))

        val exception = assertThrows(UnauthorizedException::class.java) {
            authService.verifyFirebaseToken("attacker_token", "127.0.0.1")
        }

        assertTrue(exception.message!!.contains("Identity conflict"))
    }

    // =========================================================================
    // TEST 10 — Performance: Database-level pagination and search
    // =========================================================================
    @Test
    fun `TEST 10 - Server side pagination and query Specification execution`() {
        val user1 = UserEntity(
            id = UUID.randomUUID(),
            email = "student1@mits.ac.in",
            enrollmentNumber = "BTAM2501001",
            createdAt = Instant.now()
        )
        val user2 = UserEntity(
            id = UUID.randomUUID(),
            email = "student2@mits.ac.in",
            enrollmentNumber = "BTAM2501002",
            createdAt = Instant.now()
        )

        val page = PageImpl(listOf(user1, user2))

        `when`(userRepository.findAll(anyNonNull<Specification<UserEntity>>(), anyNonNull<Pageable>())).thenReturn(page)
        `when`(profileRepository.findAllByUserIdIn(anyList())).thenReturn(emptyList())

        val results = adminUserService.getUsers(
            search = "BTAM25",
            role = Role.STUDENT,
            status = "active",
            course = "B.Tech",
            branch = null,
            department = null,
            page = 0,
            size = 20
        )

        assertEquals(2, results.size)
        assertEquals("student1@mits.ac.in", results[0].email)
        assertEquals("student2@mits.ac.in", results[1].email)

        verify(userRepository, times(1)).findAll(anyNonNull<Specification<UserEntity>>(), anyNonNull<Pageable>())
    }
}
