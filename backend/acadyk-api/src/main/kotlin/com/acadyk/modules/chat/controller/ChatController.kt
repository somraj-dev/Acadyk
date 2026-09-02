package com.acadyk.modules.chat.controller

import com.acadyk.common.ApiResponse
import com.acadyk.common.PageResponse
import com.acadyk.common.toUUID
import com.acadyk.modules.chat.dto.ConversationResponse
import com.acadyk.modules.chat.dto.FileAttachmentPayload
import com.acadyk.modules.chat.dto.MessageDto
import com.acadyk.modules.chat.dto.SendMessageRequest
import com.acadyk.modules.chat.dto.StartDirectMessageRequest
import com.acadyk.modules.chat.service.ChatService
import com.acadyk.modules.chat.service.FileMessageService
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import org.springframework.web.multipart.MultipartFile

@RestController
@RequestMapping("/api/v1")
class ChatController(
    private val chatService: ChatService,
    private val fileMessageService: FileMessageService
) {

    @GetMapping("/conversations")
    fun getConversations(): ResponseEntity<ApiResponse<List<ConversationResponse>>> {
        val result = chatService.getMyConversations()
        return ResponseEntity.ok(ApiResponse.success(result))
    }

    @PostMapping("/conversations")
    fun startConversation(@Valid @RequestBody request: StartDirectMessageRequest): ResponseEntity<ApiResponse<ConversationResponse>> {
        val result = chatService.startDirectMessage(request)
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(ApiResponse.success(result, "Conversation created"))
    }

    @GetMapping("/conversations/{id}/messages")
    fun getMessages(
        @PathVariable id: String,
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "30") size: Int
    ): ResponseEntity<ApiResponse<PageResponse<MessageDto>>> {
        val result = chatService.getMessages(id, page, size)
        return ResponseEntity.ok(ApiResponse.success(result))
    }

    @PostMapping("/conversations/{id}/messages")
    fun sendMessage(
        @PathVariable id: String,
        @Valid @RequestBody request: SendMessageRequest
    ): ResponseEntity<ApiResponse<MessageDto>> {
        val result = chatService.sendMessage(id, request)
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(ApiResponse.success(result))
    }

    /**
     * WhatsApp-style: Share a file directly in a conversation via multipart upload.
     * Pipeline: Upload S3 → PostgreSQL → WebSocket broadcast → Kafka FCM push
     */
    @PostMapping("/conversations/{id}/files", consumes = [MediaType.MULTIPART_FORM_DATA_VALUE])
    fun shareFile(
        @PathVariable id: String,
        @RequestParam("file") file: MultipartFile
    ): ResponseEntity<ApiResponse<MessageDto>> {
        val result = fileMessageService.shareFileInConversation(id.toUUID(), file)
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(ApiResponse.success(result, "File shared in conversation"))
    }

    /**
     * WhatsApp-style: Share a file using presigned URL (client already uploaded to S3).
     * Pipeline: PostgreSQL → WebSocket broadcast → Kafka FCM push
     */
    @PostMapping("/conversations/{id}/files/presigned")
    fun sharePresignedFile(
        @PathVariable id: String,
        @Valid @RequestBody attachment: FileAttachmentPayload
    ): ResponseEntity<ApiResponse<MessageDto>> {
        val result = fileMessageService.sharePresignedFileInConversation(id.toUUID(), attachment)
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(ApiResponse.success(result, "File shared in conversation"))
    }

    @PostMapping("/messages/{id}/read")
    fun markRead(@PathVariable id: String): ResponseEntity<ApiResponse<Unit>> {
        chatService.markMessageRead(id)
        return ResponseEntity.ok(ApiResponse.success(Unit, "Message marked as read"))
    }
}

