package com.acadyk.security

import com.acadyk.common.toUUIDOrNull
import com.acadyk.modules.users.entity.AuthAuditLogEntity
import com.acadyk.modules.users.repository.AuthAuditLogRepository
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import java.time.Instant
import java.util.UUID

@Service
class AuditService(
    private val authAuditLogRepository: AuthAuditLogRepository
) {
    private val logger = LoggerFactory.getLogger("SECURITY_AUDIT")

    fun logAuthEvent(
        action: String,
        userId: UUID? = null,
        email: String,
        ipAddress: String,
        success: Boolean,
        details: String? = null,
        firebaseUid: String? = null,
        deviceInfo: String? = null,
        appVersion: String? = null
    ) {
        val status = if (success) "SUCCESS" else "FAILURE"
        logger.info("[AUDIT] timestamp={} action={} userId={} email={} ip={} status={} details={}",
            Instant.now(), action, userId ?: "none", email, ipAddress, status, details ?: "None")

        try {
            authAuditLogRepository.save(
                AuthAuditLogEntity(
                    firebaseUid = firebaseUid,
                    userId = userId,
                    email = email,
                    eventType = action,
                    success = success,
                    failureReason = if (!success) details else null,
                    deviceInfo = deviceInfo,
                    appVersion = appVersion,
                    ipAddress = ipAddress,
                    createdAt = Instant.now()
                )
            )
        } catch (e: Exception) {
            logger.error("Failed to persist security audit record to DB: {}", e.message)
        }
    }

    fun logAuthEventWithStringId(
        action: String,
        userId: String?,
        email: String,
        ipAddress: String,
        success: Boolean,
        details: String? = null,
        firebaseUid: String? = null,
        deviceInfo: String? = null,
        appVersion: String? = null
    ) {
        logAuthEvent(
            action = action,
            userId = userId?.toUUIDOrNull(),
            email = email,
            ipAddress = ipAddress,
            success = success,
            details = details,
            firebaseUid = firebaseUid,
            deviceInfo = deviceInfo,
            appVersion = appVersion
        )
    }
}
