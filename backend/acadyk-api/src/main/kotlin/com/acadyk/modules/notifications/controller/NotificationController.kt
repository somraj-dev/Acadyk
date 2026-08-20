package com.acadyk.modules.notifications.controller

import com.acadyk.common.ApiResponse
import com.acadyk.common.PageResponse
import com.acadyk.modules.notifications.dto.NotificationPreferencesDto
import com.acadyk.modules.notifications.dto.NotificationResponse
import com.acadyk.modules.notifications.dto.RegisterFcmTokenRequest
import com.acadyk.modules.notifications.service.NotificationService
import jakarta.validation.Valid
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/v1/notifications")
class NotificationController(private val notificationService: NotificationService) {

    @GetMapping
    fun getNotifications(
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "20") size: Int
    ): ResponseEntity<ApiResponse<PageResponse<NotificationResponse>>> {
        val result = notificationService.getNotifications(page, size)
        return ResponseEntity.ok(ApiResponse.success(result))
    }

    @GetMapping("/unread-count")
    fun getUnreadCount(): ResponseEntity<ApiResponse<Map<String, Long>>> {
        val count = notificationService.getUnreadCount()
        return ResponseEntity.ok(ApiResponse.success(mapOf("unreadCount" to count)))
    }

    @PostMapping("/{id}/read")
    fun markAsRead(@PathVariable id: String): ResponseEntity<ApiResponse<Unit>> {
        notificationService.markAsRead(id)
        return ResponseEntity.ok(ApiResponse.success(Unit, "Notification marked as read"))
    }

    @PostMapping("/read-all")
    fun markAllAsRead(): ResponseEntity<ApiResponse<Unit>> {
        notificationService.markAllAsRead()
        return ResponseEntity.ok(ApiResponse.success(Unit, "All notifications marked as read"))
    }

    @GetMapping("/preferences")
    fun getPreferences(): ResponseEntity<ApiResponse<NotificationPreferencesDto>> {
        return ResponseEntity.ok(ApiResponse.success(notificationService.getPreferences()))
    }

    @PutMapping("/preferences")
    fun updatePreferences(@RequestBody preferences: NotificationPreferencesDto): ResponseEntity<ApiResponse<NotificationPreferencesDto>> {
        val updated = notificationService.updatePreferences(preferences)
        return ResponseEntity.ok(ApiResponse.success(updated, "Preferences updated"))
    }

    @PostMapping("/fcm-token")
    fun registerFcmToken(@Valid @RequestBody request: RegisterFcmTokenRequest): ResponseEntity<ApiResponse<Unit>> {
        notificationService.registerFcmToken(request.fcmToken)
        return ResponseEntity.ok(ApiResponse.success(Unit, "FCM token registered successfully"))
    }
}
