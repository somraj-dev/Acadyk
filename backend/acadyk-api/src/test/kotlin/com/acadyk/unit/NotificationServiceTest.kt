package com.acadyk.unit

import com.acadyk.infrastructure.fcm.FcmService
import com.acadyk.modules.notifications.entity.NotificationEntity
import com.acadyk.modules.notifications.entity.NotificationPreferenceEntity
import com.acadyk.modules.notifications.mapper.NotificationMapper
import com.acadyk.modules.notifications.repository.NotificationPreferenceRepository
import com.acadyk.modules.notifications.repository.NotificationRepository
import com.acadyk.modules.notifications.service.NotificationService
import com.acadyk.modules.profiles.entity.ProfileEntity
import com.acadyk.security.CurrentUserProvider
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import org.mockito.Mockito.*
import org.springframework.data.domain.PageImpl
import org.springframework.data.domain.PageRequest
import java.util.Optional
import java.util.UUID

class NotificationServiceTest {

    private lateinit var notificationRepository: NotificationRepository
    private lateinit var notificationPreferenceRepository: NotificationPreferenceRepository
    private lateinit var notificationMapper: NotificationMapper
    private lateinit var currentUserProvider: CurrentUserProvider
    private lateinit var fcmService: FcmService
    private lateinit var notificationService: NotificationService

    private val testUserId: UUID = UUID.randomUUID()

    @Suppress("UNCHECKED_CAST")
    private fun <T> anyNonNull(): T {
        Mockito.any<T>()
        return null as T
    }

    @BeforeEach
    fun setUp() {
        notificationRepository = mock(NotificationRepository::class.java)
        notificationPreferenceRepository = mock(NotificationPreferenceRepository::class.java)
        notificationMapper = NotificationMapper()
        currentUserProvider = mock(CurrentUserProvider::class.java)
        fcmService = mock(FcmService::class.java)

        `when`(currentUserProvider.getCurrentUserId()).thenReturn(testUserId)

        notificationService = NotificationService(
            notificationRepository = notificationRepository,
            notificationPreferenceRepository = notificationPreferenceRepository,
            notificationMapper = notificationMapper,
            currentUserProvider = currentUserProvider,
            fcmService = fcmService
        )
    }

    @Test
    fun `getNotifications returns mapped notification responses`() {
        val recipient = ProfileEntity(
            id = testUserId,
            username = "recipient_user",
            email = "recipient@acadyk.com",
            fullName = "Recipient User"
        )

        val notif = NotificationEntity(
            id = UUID.randomUUID(),
            recipient = recipient,
            type = "post_like",
            title = "New reaction",
            body = "Somraj liked your post"
        )

        val pageable = PageRequest.of(0, 20)
        `when`(notificationRepository.findAllByRecipientIdOrderByCreatedAtDesc(testUserId, pageable))
            .thenReturn(PageImpl(listOf(notif), pageable, 1))

        val result = notificationService.getNotifications(0, 20)

        assertNotNull(result)
        assertEquals(1, result.content.size)
        assertEquals("New reaction", result.content[0].title)
    }

    @Test
    fun `getPreferences returns preferences when found`() {
        val pref = NotificationPreferenceEntity(
            id = UUID.randomUUID(),
            profileId = testUserId,
            pushEnabled = true,
            emailEnabled = true
        )

        `when`(notificationPreferenceRepository.findByProfileId(testUserId)).thenReturn(Optional.of(pref))

        val result = notificationService.getPreferences()

        assertNotNull(result)
        assertTrue(result.pushEnabled)
        assertTrue(result.emailEnabled)
    }
}
