package com.acadyk.modules.files.dto

import jakarta.validation.constraints.NotBlank

data class PresignedUrlRequest(
    @field:NotBlank(message = "File name is required")
    val fileName: String,

    @field:NotBlank(message = "Content type is required")
    val contentType: String
)

data class PresignedUrlResponse(
    val uploadUrl: String,
    val fileUrl: String,
    val fileKey: String
)

data class UploadFileResponse(
    val id: String,
    val fileUrl: String,
    val fileKey: String,
    val fileName: String,
    val fileSize: Long
)
