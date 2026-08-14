package com.acadyk.infrastructure.observability

import jakarta.servlet.FilterChain
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.slf4j.MDC
import org.springframework.core.Ordered
import org.springframework.core.annotation.Order
import org.springframework.stereotype.Component
import org.springframework.web.filter.OncePerRequestFilter
import java.util.UUID

@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
class MdcLoggingFilter : OncePerRequestFilter() {

    companion object {
        const val REQUEST_ID_HEADER = "X-Request-ID"
        const val CORRELATION_ID_HEADER = "X-Correlation-ID"
        const val MDC_REQUEST_ID = "requestId"
        const val MDC_CORRELATION_ID = "correlationId"
        const val MDC_CLIENT_IP = "clientIp"
        const val MDC_HTTP_METHOD = "httpMethod"
        const val MDC_REQUEST_URI = "requestUri"
    }

    override fun doFilterInternal(
        request: HttpServletRequest,
        response: HttpServletResponse,
        filterChain: FilterChain
    ) {
        val requestId = request.getHeader(REQUEST_ID_HEADER) ?: UUID.randomUUID().toString()
        val correlationId = request.getHeader(CORRELATION_ID_HEADER) ?: requestId
        val clientIp = extractClientIp(request)

        MDC.put(MDC_REQUEST_ID, requestId)
        MDC.put(MDC_CORRELATION_ID, correlationId)
        MDC.put(MDC_CLIENT_IP, clientIp)
        MDC.put(MDC_HTTP_METHOD, request.method)
        MDC.put(MDC_REQUEST_URI, request.requestURI)

        response.setHeader(REQUEST_ID_HEADER, requestId)
        response.setHeader(CORRELATION_ID_HEADER, correlationId)

        val startTime = System.currentTimeMillis()
        try {
            filterChain.doFilter(request, response)
        } finally {
            val duration = System.currentTimeMillis() - startTime
            MDC.put("executionTimeMs", duration.toString())
            MDC.clear()
        }
    }

    private fun extractClientIp(request: HttpServletRequest): String {
        val xForwardedFor = request.getHeader("X-Forwarded-For")
        if (!xForwardedFor.isNullOrBlank()) {
            return xForwardedFor.split(",")[0].trim()
        }
        return request.remoteAddr ?: "unknown"
    }
}
