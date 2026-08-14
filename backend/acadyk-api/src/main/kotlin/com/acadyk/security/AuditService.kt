package com.acadyk.security

import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import java.time.Instant

@Service
class AuditService {
    private val logger = LoggerFactory.getLogger("SECURITY_AUDIT")

    fun logAuthEvent(action: String, userId: String, email: String, ipAddress: String, success: Boolean, details: String? = null) {
        val status = if (success) "SUCCESS" else "FAILURE"
        logger.info("[AUDIT] timestamp={} action={} userId={} email={} ip={} status={} details={}",
            Instant.now(), action, userId, email, ipAddress, status, details ?: "None")
    }
}
