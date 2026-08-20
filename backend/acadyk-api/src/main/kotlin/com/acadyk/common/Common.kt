package com.acadyk.common

import jakarta.persistence.Column
import jakarta.persistence.MappedSuperclass
import org.springframework.data.domain.Page
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.MethodArgumentNotValidException
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.RestControllerAdvice
import java.time.Instant
import java.util.UUID

@MappedSuperclass
abstract class BaseEntity(
    @Column(nullable = false, updatable = false)
    val createdAt: Instant = Instant.now(),

    @Column(nullable = false)
    var updatedAt: Instant = Instant.now()
)

data class ApiResponse<T>(
    val success: Boolean,
    val message: String? = null,
    val data: T? = null,
    val timestamp: Instant = Instant.now()
) {
    companion object {
        fun <T> success(data: T, message: String? = null): ApiResponse<T> =
            ApiResponse(success = true, message = message, data = data)

        fun <T> error(message: String): ApiResponse<T> =
            ApiResponse(success = false, message = message, data = null)
    }
}

data class PageResponse<T>(
    val content: List<T>,
    val pageNumber: Int,
    val pageSize: Int,
    val totalElements: Long,
    val totalPages: Int,
    val isLast: Boolean
) {
    companion object {
        fun <T> from(page: Page<T>): PageResponse<T> {
            return PageResponse(
                content = page.content,
                pageNumber = page.number,
                pageSize = page.size,
                totalElements = page.totalElements,
                totalPages = page.totalPages,
                isLast = page.isLast
            )
        }

        fun <E, T> from(page: Page<E>, mapper: (E) -> T): PageResponse<T> {
            return PageResponse(
                content = page.content.map(mapper),
                pageNumber = page.number,
                pageSize = page.size,
                totalElements = page.totalElements,
                totalPages = page.totalPages,
                isLast = page.isLast
            )
        }
    }
}

class ResourceNotFoundException(message: String) : RuntimeException(message)
class BadRequestException(message: String) : RuntimeException(message)
class UnauthorizedException(message: String) : RuntimeException(message)
class ForbiddenException(message: String) : RuntimeException(message)
class ConflictException(message: String) : RuntimeException(message)

fun String.toUUID(): UUID = try {
    UUID.fromString(this)
} catch (e: Exception) {
    throw BadRequestException("Invalid UUID format: $this")
}

fun String?.toUUIDOrNull(): UUID? = this?.let {
    try {
        UUID.fromString(it)
    } catch (_: Exception) {
        null
    }
}

@RestControllerAdvice
class GlobalExceptionHandler {

    @ExceptionHandler(ResourceNotFoundException::class)
    fun handleNotFound(e: ResourceNotFoundException): ResponseEntity<ApiResponse<Unit>> {
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(ApiResponse.error(e.message ?: "Resource not found"))
    }

    @ExceptionHandler(BadRequestException::class)
    fun handleBadRequest(e: BadRequestException): ResponseEntity<ApiResponse<Unit>> {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(ApiResponse.error(e.message ?: "Bad request"))
    }

    @ExceptionHandler(ConflictException::class)
    fun handleConflict(e: ConflictException): ResponseEntity<ApiResponse<Unit>> {
        return ResponseEntity.status(HttpStatus.CONFLICT).body(ApiResponse.error(e.message ?: "Resource conflict"))
    }

    @ExceptionHandler(IllegalArgumentException::class)
    fun handleIllegalArgument(e: IllegalArgumentException): ResponseEntity<ApiResponse<Unit>> {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(ApiResponse.error(e.message ?: "Invalid UUID or argument"))
    }

    @ExceptionHandler(UnauthorizedException::class)
    fun handleUnauthorized(e: UnauthorizedException): ResponseEntity<ApiResponse<Unit>> {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(ApiResponse.error(e.message ?: "Unauthorized"))
    }

    @ExceptionHandler(ForbiddenException::class)
    fun handleForbidden(e: ForbiddenException): ResponseEntity<ApiResponse<Unit>> {
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(ApiResponse.error(e.message ?: "Forbidden"))
    }

    @ExceptionHandler(MethodArgumentNotValidException::class)
    fun handleValidation(e: MethodArgumentNotValidException): ResponseEntity<ApiResponse<Unit>> {
        val errorMessage = e.bindingResult.fieldErrors.joinToString(", ") { "${it.field}: ${it.defaultMessage}" }
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(ApiResponse.error(errorMessage))
    }

    @ExceptionHandler(Exception::class)
    fun handleGeneric(e: Exception): ResponseEntity<ApiResponse<Unit>> {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(ApiResponse.error(e.message ?: "An unexpected error occurred"))
    }
}
