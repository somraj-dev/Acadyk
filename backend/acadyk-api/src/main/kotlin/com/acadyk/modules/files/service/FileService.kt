package com.acadyk.modules.files.service

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

    fun generatePresignedUploadUrl(request: PresignedUrlRequest): PresignedUrlResponse {
        val currentUserId = try { currentUserProvider.getCurrentUserId() } catch (_: Exception) { "anonymous" }
        val ext = request.fileName.substringAfterLast('.', "bin")
        val fileKey = "uploads/$currentUserId/${UUID.randomUUID()}.$ext"
        val fileUrl = "https://$bucketName.s3.amazonaws.com/$fileKey"
        val uploadUrl = "https://$bucketName.s3.amazonaws.com/$fileKey?mockUploadSignature=true"

        return PresignedUrlResponse(uploadUrl, fileUrl, fileKey)
    }

    fun uploadMultipartFile(file: MultipartFile, bucket: String?): UploadFileResponse {
        val currentUserId = try { currentUserProvider.getCurrentUserId() } catch (_: Exception) { "anonymous" }

        val targetBucket = bucket ?: bucketName
        val originalFilename = file.originalFilename ?: "upload.bin"
        val ext = originalFilename.substringAfterLast('.', "bin")
        val fileKey = "uploads/$currentUserId/${UUID.randomUUID()}.$ext"

        val fileUrl = s3StorageService.uploadFile(
            key = fileKey,
            inputStream = file.inputStream,
            contentLength = file.size,
            contentType = file.contentType ?: "application/octet-stream",
            bucket = targetBucket
        )

        val entity = fileRepository.save(
            FileEntity(
                uploaderId = currentUserId,
                fileKey = fileKey,
                fileName = originalFilename,
                contentType = file.contentType ?: "application/octet-stream",
                fileSizeBytes = file.size,
                bucketName = targetBucket
            )
        )

        return UploadFileResponse(
            id = entity.id,
            fileUrl = fileUrl,
            fileKey = entity.fileKey,
            fileName = entity.fileName,
            fileSize = entity.fileSizeBytes
        )
    }
}
