package com.acadyk.security

import com.fasterxml.jackson.databind.ObjectMapper
import com.google.auth.oauth2.GoogleCredentials
import com.google.firebase.FirebaseApp
import com.google.firebase.FirebaseOptions
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.FirebaseToken
import io.jsonwebtoken.Jwts
import io.jsonwebtoken.security.Keys
import jakarta.annotation.PostConstruct
import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.core.io.ResourceLoader
import org.springframework.stereotype.Component
import java.io.InputStream
import java.nio.charset.StandardCharsets
import java.util.Base64
import javax.crypto.SecretKey

data class VerifiedTokenUser(
    val uid: String,
    val email: String,
    val name: String?,
    val picture: String?,
    val isEmailVerified: Boolean
)

@Component
class FirebaseTokenVerifier(
    @Value("\${firebase.service-account-path:}") private val serviceAccountPath: String,
    @Value("\${acadyk.auth.dev-mode-enabled:true}") private val devModeEnabled: Boolean,
    @Value("\${jwt.secret:acadyk-production-super-secret-key-32-chars!}") private val jwtSecretString: String,
    private val resourceLoader: ResourceLoader,
    private val objectMapper: ObjectMapper
) {
    private val logger = LoggerFactory.getLogger(javaClass)
    private var firebaseAppInitialized = false
    private lateinit var jwtSecretKey: SecretKey

    @PostConstruct
    fun init() {
        val secretBytes = if (jwtSecretString.length >= 32) {
            jwtSecretString.toByteArray(StandardCharsets.UTF_8)
        } else {
            jwtSecretString.padEnd(32, '!').toByteArray(StandardCharsets.UTF_8)
        }
        jwtSecretKey = Keys.hmacShaKeyFor(secretBytes)

        try {
            if (serviceAccountPath.isNotBlank() && FirebaseApp.getApps().isEmpty()) {
                val resource = resourceLoader.getResource(serviceAccountPath)
                if (resource.exists()) {
                    val serviceAccountStream: InputStream = resource.inputStream
                    val options = FirebaseOptions.builder()
                        .setCredentials(GoogleCredentials.fromStream(serviceAccountStream))
                        .build()
                    FirebaseApp.initializeApp(options)
                    firebaseAppInitialized = true
                    logger.info("Firebase Admin SDK successfully initialized.")
                } else {
                    logger.warn("Firebase service account file not found at: $serviceAccountPath. Operating in dev token verification mode.")
                }
            }
        } catch (e: Exception) {
            logger.warn("Firebase initialization warning (local dev verification mode active): ${e.message}")
        }
    }

    fun verifyToken(token: String): VerifiedTokenUser? {
        val cleanToken = token.trim().removeSurrounding("\"")
        if (cleanToken.isBlank()) return null

        // 1. Production Firebase Admin SDK Verification (MANDATORY & PRIMARY)
        if (firebaseAppInitialized) {
            try {
                val firebaseToken: FirebaseToken = FirebaseAuth.getInstance().verifyIdToken(cleanToken)
                return VerifiedTokenUser(
                    uid = firebaseToken.uid,
                    email = firebaseToken.email ?: "${firebaseToken.uid}@acadyk.com",
                    name = firebaseToken.name,
                    picture = firebaseToken.picture,
                    isEmailVerified = firebaseToken.isEmailVerified
                )
            } catch (e: Exception) {
                logger.debug("Firebase ID token verification failed via Admin SDK: ${e.message}")
            }
        }

        // 2. Fallback HMAC Signed JWT verification (for internal microservice tokens)
        try {
            val claims = Jwts.parser()
                .verifyWith(jwtSecretKey)
                .build()
                .parseSignedClaims(cleanToken)
                .payload

            val email = claims["email"]?.toString() ?: claims.subject ?: "25am1ab4@mitsgwl.ac.in"
            val uid = claims.subject ?: email

            return VerifiedTokenUser(
                uid = uid,
                email = email,
                name = claims["name"]?.toString(),
                picture = claims["picture"]?.toString(),
                isEmailVerified = true
            )
        } catch (_: Exception) {}

        // 3. Dev-only mock tokens (STRICTLY when devModeEnabled == true)
        if (devModeEnabled) {
            // Standard 3-part JWT Payload Extraction for local testing
            if (cleanToken.contains(".")) {
                val parts = cleanToken.split(".")
                if (parts.size == 3) {
                    try {
                        val payloadBytes = Base64.getUrlDecoder().decode(parts[1])
                        val payloadJson = String(payloadBytes, StandardCharsets.UTF_8)
                        val jsonNode = objectMapper.readTree(payloadJson)

                        val uid = jsonNode.path("user_id").asText().takeIf { it.isNotBlank() }
                            ?: jsonNode.path("sub").asText().takeIf { it.isNotBlank() }
                            ?: jsonNode.path("uid").asText().takeIf { it.isNotBlank() }
                        val email = jsonNode.path("email").asText().takeIf { it.isNotBlank() }
                        val name = jsonNode.path("name").asText().takeIf { it.isNotBlank() }
                        val picture = jsonNode.path("picture").asText().takeIf { it.isNotBlank() }
                        val isEmailVerified = if (jsonNode.has("email_verified")) jsonNode.path("email_verified").asBoolean(true) else true

                        if (!uid.isNullOrBlank() || !email.isNullOrBlank()) {
                            val effectiveEmail = email ?: if (uid?.contains("@") == true) uid else "$uid@mitsgwl.ac.in"
                            val effectiveUid = uid ?: effectiveEmail
                            return VerifiedTokenUser(
                                uid = effectiveUid,
                                email = effectiveEmail,
                                name = name,
                                picture = picture,
                                isEmailVerified = isEmailVerified
                            )
                        }
                    } catch (_: Exception) {}
                }
            }

            if (cleanToken.startsWith("test-token-") || cleanToken.startsWith("session_") || cleanToken.startsWith("token_") || cleanToken.startsWith("user_")) {
                val identifier = cleanToken
                    .removePrefix("test-token-")
                    .removePrefix("session_")
                    .removePrefix("token_")
                val email = if (identifier.contains("@")) identifier else "$identifier@mitsgwl.ac.in"
                return VerifiedTokenUser(
                    uid = identifier,
                    email = email,
                    name = "Test User $identifier",
                    picture = null,
                    isEmailVerified = true
                )
            }

            if (cleanToken.contains("@") && cleanToken.contains(".")) {
                return VerifiedTokenUser(
                    uid = cleanToken,
                    email = cleanToken,
                    name = "Acadyk User",
                    picture = null,
                    isEmailVerified = true
                )
            }
        }

        return null
    }
}
