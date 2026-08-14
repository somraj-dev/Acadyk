package com.acadyk.infrastructure.s3

import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service
import software.amazon.awssdk.core.sync.RequestBody
import software.amazon.awssdk.services.s3.S3Client
import software.amazon.awssdk.services.s3.model.GetObjectRequest
import software.amazon.awssdk.services.s3.model.PutObjectRequest
import software.amazon.awssdk.services.s3.presigner.S3Presigner
import software.amazon.awssdk.services.s3.presigner.model.GetObjectPresignRequest
import software.amazon.awssdk.services.s3.presigner.model.PutObjectPresignRequest
import java.io.InputStream
import java.time.Duration

@Service
class S3StorageService(
    private val s3Client: S3Client,
    private val s3Presigner: S3Presigner,
    @Value("\${aws.s3.bucket:acadyk-media-production}") private val defaultBucket: String,
    @Value("\${aws.s3.region:us-east-1}") private val region: String
) {
    private val logger = LoggerFactory.getLogger(javaClass)

    /**
     * Upload binary directly to S3 bucket (least privilege)
     */
    fun uploadFile(
        key: String,
        inputStream: InputStream,
        contentLength: Long,
        contentType: String,
        bucket: String = defaultBucket
    ): String {
        return try {
            val request = PutObjectRequest.builder()
                .bucket(bucket)
                .key(key)
                .contentType(contentType)
                .build()

            s3Client.putObject(request, RequestBody.fromInputStream(inputStream, contentLength))
            "https://$bucket.s3.$region.amazonaws.com/$key"
        } catch (e: Exception) {
            logger.warn("S3 direct upload fallback (local/dev mode active): ${e.message}")
            "http://localhost:8080/api/v1/media/public/$bucket/$key"
        }
    }

    /**
     * Generate Pre-signed PUT URL for direct client-to-S3 upload
     */
    fun generatePresignedUploadUrl(
        key: String,
        contentType: String,
        bucket: String = defaultBucket,
        expiration: Duration = Duration.ofMinutes(15)
    ): Pair<String, String> {
        val fileUrl = "https://$bucket.s3.$region.amazonaws.com/$key"
        return try {
            val objectRequest = PutObjectRequest.builder()
                .bucket(bucket)
                .key(key)
                .contentType(contentType)
                .build()

            val presignRequest = PutObjectPresignRequest.builder()
                .signatureDuration(expiration)
                .putObjectRequest(objectRequest)
                .build()

            val presignedRequest = s3Presigner.presignPutObject(presignRequest)
            Pair(presignedRequest.url().toString(), fileUrl)
        } catch (e: Exception) {
            logger.warn("S3 presigned upload URL generator fallback: ${e.message}")
            Pair("http://localhost:8080/api/v1/files/upload", fileUrl)
        }
    }

    /**
     * Generate Pre-signed GET URL for secure temporary download of private documents (resumes, certificates)
     */
    fun generatePresignedDownloadUrl(
        key: String,
        bucket: String = defaultBucket,
        expiration: Duration = Duration.ofMinutes(30)
    ): String {
        return try {
            val getObjectRequest = GetObjectRequest.builder()
                .bucket(bucket)
                .key(key)
                .build()

            val presignRequest = GetObjectPresignRequest.builder()
                .signatureDuration(expiration)
                .getObjectRequest(getObjectRequest)
                .build()

            val presignedRequest = s3Presigner.presignGetObject(presignRequest)
            presignedRequest.url().toString()
        } catch (e: Exception) {
            logger.warn("S3 presigned download URL generator fallback: ${e.message}")
            "https://$bucket.s3.$region.amazonaws.com/$key"
        }
    }
}
