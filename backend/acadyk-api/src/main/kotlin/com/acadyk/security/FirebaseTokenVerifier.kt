package com.acadyk.security

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
    private val resourceLoader: ResourceLoader
) {
    private val logger = LoggerFactory.getLogger(javaClass)
    private var firebaseAppInitialized = false
    private val jwtSecretKey: SecretKey = Keys.hmacShaKeyFor("acadyk-production-super-secret-key-32-chars!".toByteArray())

    @PostConstruct
    fun init() {
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
        if (token.isBlank()) return null

        // 1. Production Firebase Admin SDK Verification
        if (firebaseAppInitialized) {
            try {
                val firebaseToken: FirebaseToken = FirebaseAuth.getInstance().verifyIdToken(token)
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

        // 2. JWT Fallback / Dev verification (for dev testing and local environments)
        try {
            val claims = Jwts.parser()
                .verifyWith(jwtSecretKey)
                .build()
                .parseSignedClaims(token)
                .payload

            return VerifiedTokenUser(
                uid = claims.subject ?: "user_dev",
                email = claims["email"]?.toString() ?: "developer@acadyk.com",
                name = claims["name"]?.toString() ?: "Somraj Lodhi",
                picture = claims["picture"]?.toString(),
                isEmailVerified = true
            )
        } catch (e: Exception) {
            logger.debug("Fallback JWT verification failed: ${e.message}")
        }

        // 3. Simple Bearer test token format (for automated integration tests)
        if (token.startsWith("test-token-")) {
            val uid = token.removePrefix("test-token-")
            return VerifiedTokenUser(
                uid = uid,
                email = "$uid@acadyk.com",
                name = "Test User $uid",
                picture = null,
                isEmailVerified = true
            )
        }

        return null
    }
}
