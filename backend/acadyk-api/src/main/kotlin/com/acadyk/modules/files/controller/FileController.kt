package com.acadyk.modules.files.controller

import com.acadyk.common.ApiResponse
import com.acadyk.modules.files.dto.PresignedUrlRequest
import com.acadyk.modules.files.dto.PresignedUrlResponse
import com.acadyk.modules.files.dto.UploadFileResponse
import com.acadyk.modules.files.service.FileService
import jakarta.validation.Valid
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import org.springframework.web.multipart.MultipartFile

@RestController
@RequestMapping("/api/v1/files")
class FileController(private val fileService: FileService) {

    @PostMapping("/presigned-upload-url")
    fun getPresignedUploadUrl(@Valid @RequestBody request: PresignedUrlRequest): ResponseEntity<ApiResponse<PresignedUrlResponse>> {
        val result = fileService.generatePresignedUploadUrl(request)
        return ResponseEntity.ok(ApiResponse.success(result))
    }

    @PostMapping("/upload", consumes = [MediaType.MULTIPART_FORM_DATA_VALUE])
    fun uploadFile(
        @RequestParam("file") file: MultipartFile
    ): ResponseEntity<ApiResponse<UploadFileResponse>> {
        val result = fileService.uploadMultipartFile(file)
        return ResponseEntity.ok(ApiResponse.success(result))
    }
}
