package com.acadyk.infrastructure.fcm

import com.google.firebase.messaging.FirebaseMessaging
import com.google.firebase.messaging.Message
import com.google.firebase.messaging.Notification
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import java.util.concurrent.ConcurrentHashMap

@Service
class FcmService {
    private val logger = LoggerFactory.getLogger(javaClass)

    // Store active FCM device registration tokens per profile ID
    private val userTokens = ConcurrentHashMap<String, MutableSet<String>>()

    fun registerToken(userId: String, token: String) {
        userTokens.computeIfAbsent(userId) { ConcurrentHashMap.newKeySet() }.add(token)
        logger.debug("FCM token registered for user: $userId")
    }

    fun removeToken(userId: String, token: String) {
        userTokens[userId]?.remove(token)
    }

    fun getUserTokens(userId: String): Set<String> {
        return userTokens[userId] ?: emptySet()
    }

    /**
     * Send FCM push notification safely.
     * Guaranteed not to throw or fail calling business transactions.
     */
    fun sendPushNotification(
        recipientId: String,
        title: String,
        body: String,
        dataPayload: Map<String, String> = emptyMap()
    ) {
        val tokens = getUserTokens(recipientId)
        if (tokens.isEmpty()) {
            logger.debug("No FCM tokens registered for user $recipientId. In-app notification preserved.")
            return
        }

        tokens.forEach { token ->
            try {
                val notification = Notification.builder()
                    .setTitle(title)
                    .setBody(body)
                    .build()

                val messageBuilder = Message.builder()
                    .setToken(token)
                    .setNotification(notification)

                dataPayload.forEach { (k, v) -> messageBuilder.putData(k, v) }

                val message = messageBuilder.build()
                FirebaseMessaging.getInstance().sendAsync(message)
                logger.debug("FCM push dispatched to user $recipientId")
            } catch (e: Exception) {
                logger.warn("FCM push delivery failed for token ($token): ${e.message}")
            }
        }
    }
}
