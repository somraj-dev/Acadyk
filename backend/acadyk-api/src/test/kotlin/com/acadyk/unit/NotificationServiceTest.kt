package com.acadyk.unit

import com.acadyk.modules.notifications.entity.NotificationEntity
import com.acadyk.modules.notifications.entity.NotificationPreferencesEntity
import com.acadyk.modules.notifications.repository.NotificationRepository
import com.acadyk.modules.notifications.repository.NotificationPreferencesRepository
import com.acadyk.modules.notifications.service.NotificationService
import com.acadyk.security.CurrentUserProvider
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.mockito.Mockito.*
import org.springframework.data.domain.PageImpl
import org.springframework.data.domain.PageRequest
import java.util.Optional
import java.util.UUID

class NotificationServiceTest {

    private lateinit var notificationRepository: NotificationRepository
    private lateinit var preferencesRepository: NotificationPreferencesRepository
    private lateinit var currentUserProvider: CurrentUserProvider
    private lateinit var notificationService: NotificationService

    private val testUserId = UUID.randomUUID()

    @BeforeEach
    fun setUp() {
        notificationRepository = mock(NotificationRepository::class.java)
        preferencesRepository = mock(NotificationPreferencesRepository::class.java)
        currentUserProvider = mock(CurrentUserProvider::class.java)

        `when`(currentUserProvider.getCurrentUserId()).thenReturn(testUserId)

        notificationService = NotificationService(
            notificationRepository = notificationRepository,
            preferencesRepository = preferencesRepository,
            currentUserProvider = currentUserProvider
        )
    }

    @Test
    fun `getUserNotifications returns user notifications list`() {
        val pageable = PageRequest.of(0, 10)
        val notifList = listOf(
            NotificationEntity(
                id = UUID.randomUUID(),
                userId = testUserId,
                title = "New Connection",
                body = "Somraj connected with you",
                category = "CONNECTIONS"
            )
        )

        `when`(notificationRepository.findAllByUserIdOrderByCreatedAtDesc(testUserId, pageable))
            .thenReturn(PageImpl(notifList, pageable, 1))

        val result = notificationService.getUserNotifications(pageable)

        assertNotNull(result)
        assertEquals(1, result.content.size)
        assertEquals("New Connection", result.content[0].title)
    }

    @Test
    fun `markAllAsRead updates all unread notifications to read`() {
        notificationService.markAllAsRead()

        verify(notificationRepository, times(1)).markAllAsRead(testUserId)
    }

    @Test
    fun `updatePreferences saves user notification toggle preferences`() {
        val prefs = NotificationPreferencesEntity(
            userId = testUserId,
            pushEnabled = true,
            emailEnabled = false,
            likesEnabled = true
        )

        `when`(preferencesRepository.findById(testUserId)).thenReturn(Optional.of(prefs))
        `when`(preferencesRepository.save(any(NotificationPreferencesEntity::class.java))).thenAnswer { it.arguments[0] }

        val updated = notificationService.updatePreferences(mapOf("emailEnabled" to true))

        assertNotNull(updated)
        verify(preferencesRepository, times(1)).save(any())
    }
}
