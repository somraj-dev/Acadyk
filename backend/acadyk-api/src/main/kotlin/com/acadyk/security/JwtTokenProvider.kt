package com.acadyk.security

import io.jsonwebtoken.Claims
import io.jsonwebtoken.Jwts
import io.jsonwebtoken.security.Keys
import org.springframework.stereotype.Component
import java.util.Date
import javax.crypto.SecretKey

@Component
class JwtTokenProvider {

    private val secret: SecretKey = Keys.hmacShaKeyFor("acadyk-production-super-secret-key-32-chars!".toByteArray())
    private val validityInMs: Long = 3600000 * 24 * 7 // 7 days

    fun createToken(userId: String, email: String, username: String): String {
        val now = Date()
        val validity = Date(now.time + validityInMs)

        return Jwts.builder()
            .subject(userId)
            .claim("email", email)
            .claim("username", username)
            .issuedAt(now)
            .expiration(validity)
            .signWith(secret)
            .compact()
    }

    fun getClaims(token: String): Claims {
        return Jwts.parser()
            .verifyWith(secret)
            .build()
            .parseSignedClaims(token)
            .payload
    }

    fun validateToken(token: String): Boolean {
        return try {
            val claims = getClaims(token)
            !claims.expiration.before(Date())
        } catch (e: Exception) {
            false
        }
    }
}
