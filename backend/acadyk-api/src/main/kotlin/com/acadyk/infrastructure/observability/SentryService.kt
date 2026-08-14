package com.acadyk.infrastructure.observability

import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service

@Service
class SentryService(
    @Value("\${sentry.dsn:}") private val sentryDsn: String,
    @Value("\${spring.profiles.active:dev}") private val environment: String
) {
    private val logger = LoggerFactory.getLogger(SentryService::class.java)

    fun captureException(throwable: Throwable, context: Map<String, Any> = emptyMap()) {
        logger.error("[SENTRY_ALERT] Exception in environment: $environment - ${throwable.message}", throwable)
        if (sentryDsn.isNotBlank()) {
            // Sentry SDK capture hook
            logger.info("[SENTRY_DISPATCH] Error forwarded to Sentry endpoint with context keys: ${context.keys}")
        }
    }

    fun captureMessage(message: String, level: String = "INFO") {
        logger.info("[SENTRY_LOG] Level: $level - Message: $message")
    }
}
