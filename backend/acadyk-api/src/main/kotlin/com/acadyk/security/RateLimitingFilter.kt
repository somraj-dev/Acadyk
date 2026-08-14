package com.acadyk.security

import jakarta.servlet.FilterChain
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.springframework.http.HttpStatus
import org.springframework.stereotype.Component
import org.springframework.web.filter.OncePerRequestFilter
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.atomic.AtomicInteger

@Component
class RateLimitingFilter : OncePerRequestFilter() {

    private val requestCounts = ConcurrentHashMap<String, RequestBucket>()
    private val maxRequestsPerMinute = 120

    data class RequestBucket(
        val count: AtomicInteger = AtomicInteger(0),
        var resetTime: Long = System.currentTimeMillis() + 60000
    )

    override fun doFilterInternal(
        request: HttpServletRequest,
        response: HttpServletResponse,
        filterChain: FilterChain
    ) {
        val clientIp = request.getHeader("X-Forwarded-For") ?: request.remoteAddr ?: "unknown"
        val currentTime = System.currentTimeMillis()

        val bucket = requestCounts.compute(clientIp) { _, existing ->
            if (existing == null || currentTime > existing.resetTime) {
                RequestBucket(AtomicInteger(1), currentTime + 60000)
            } else {
                existing.count.incrementAndGet()
                existing
            }
        }

        if (bucket != null && bucket.count.get() > maxRequestsPerMinute) {
            response.status = HttpStatus.TOO_MANY_REQUESTS.value()
            response.contentType = "application/json"
            response.writer.write("""{"success":false,"message":"Rate limit exceeded. Please retry in a minute."}""")
            return
        }

        // Add standard security headers
        response.setHeader("X-Content-Type-Options", "nosniff")
        response.setHeader("X-Frame-Options", "DENY")
        response.setHeader("X-XSS-Protection", "1; mode=block")
        response.setHeader("Strict-Transport-Security", "max-age=31536000; includeSubDomains")

        filterChain.doFilter(request, response)
    }
}
