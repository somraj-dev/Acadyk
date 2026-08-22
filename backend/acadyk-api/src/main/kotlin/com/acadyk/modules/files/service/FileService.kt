package com.acadyk.modules.files.service

import com.acadyk.common.BadRequestException
import com.acadyk.infrastructure.s3.S3StorageService
import com.acadyk.modules.files.dto.PresignedUrlRequest
import com.acadyk.modules.files.dto.PresignedUrlResponse
import com.acadyk.modules.files.dto.UploadFileResponse
import com.acadyk.modules.files.entity.FileEntity
import com.acadyk.modules.files.repository.FileRepository
import com.acadyk.security.CurrentUserProvider
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import org.springframework.web.multipart.MultipartFile
import java.util.UUID

@Service
@Transactional
class FileService(
    private val fileRepository: FileRepository,
    private val s3StorageService: S3StorageService,
    private val currentUserProvider: CurrentUserProvider,
    @Value("\${aws.s3.bucket:acadyk-media-production}") private val bucketName: String
) {
    companion object {
        const val MAX_FILE_SIZE_BYTES = 10 * 1024 * 1024L // 10 MB
        val ALLOWED_EXTENSIONS = setOf("jpg", "jpeg", "png", "webp", "gif", "pdf", "doc", "docx", "mp4")
        val ALLOWED_MIME_TYPES = setOf(
            "image/jpeg", "image/png", "image/webp", "image/gif",
            "application/pdf", "application/msword",
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            "video/mp4"
        )
    }

    fun generatePresignedUploadUrl(request: PresignedUrlRequest): PresignedUrlResponse {
        val currentUserId = try { currentUserProvider.getCurrentUserId().toString() } catch (_: Exception) { "anonymous" }
        val ext = request.fileName.substringAfterLast('.', "bin").lowercase()

        if (ext !in ALLOWED_EXTENSIONS) {
            throw BadRequestException("File extension '.$ext' is not permitted. Allowed: ${ALLOWED_EXTENSIONS.joinToString(", ")}")
        }
        if (request.contentType.lowercase() !in ALLOWED_MIME_TYPES) {
            throw BadRequestException("Content type '${request.contentType}' is not permitted")
        }

        val fileKey = "uploads/$currentUserId/${UUID.randomUUID()}.$ext"
        val (uploadUrl, fileUrl) = s3StorageService.generatePresignedUploadUrl(
            key = fileKey,
            contentType = request.contentType,
            bucket = bucketName
        )

        return PresignedUrlResponse(uploadUrl, fileUrl, fileKey)
    }

    fun uploadMultipartFile(file: MultipartFile): UploadFileResponse {
        if (file.isEmpty) {
            throw BadRequestException("Uploaded file cannot be empty")
        }
        if (file.size > MAX_FILE_SIZE_BYTES) {
            throw BadRequestException("File size (${file.size / (1024 * 1024)} MB) exceeds maximum allowed size of 10 MB")
        }

        val originalFilename = file.originalFilename ?: "upload.bin"
        val ext = originalFilename.substringAfterLast('.', "bin").lowercase()

        if (ext !in ALLOWED_EXTENSIONS) {
            throw BadRequestException("File extension '.$ext' is not permitted. Allowed: ${ALLOWED_EXTENSIONS.joinToString(", ")}")
        }

        val contentType = file.contentType ?: "application/octet-stream"
        if (contentType.lowercase() !in ALLOWED_MIME_TYPES) {
            throw BadRequestException("MIME type '$contentType' is not permitted")
        }

        val currentUserId = try { currentUserProvider.getCurrentUserId() } catch (_: Exception) { null }
        val fileKey = "uploads/${currentUserId ?: "anonymous"}/${UUID.randomUUID()}.$ext"

        val fileUrl = s3StorageService.uploadFile(
            key = fileKey,
            inputStream = file.inputStream,
            contentLength = file.size,
            contentType = contentType,
            bucket = bucketName
        )

        val entity = fileRepository.save(
            FileEntity(
                uploaderId = currentUserId,
                fileKey = fileKey,
                fileName = originalFilename,
                contentType = contentType,
                fileSizeBytes = file.size,
                bucketName = bucketName
            )
        )

        return UploadFileResponse(
            id = entity.id.toString(),
            fileUrl = fileUrl,
            fileKey = entity.fileKey,
            fileName = entity.fileName,
            fileSize = entity.fileSizeBytes
        )
    }
}
