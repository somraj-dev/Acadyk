package com.acadyk.modules.chat.controller

import com.acadyk.common.ApiResponse
import com.acadyk.common.PageResponse
import com.acadyk.modules.chat.dto.ConversationResponse
import com.acadyk.modules.chat.dto.MessageDto
import com.acadyk.modules.chat.dto.SendMessageRequest
import com.acadyk.modules.chat.dto.StartDirectMessageRequest
import com.acadyk.modules.chat.service.ChatService
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/v1")
@CrossOrigin(origins = ["*"])
class ChatController(private val chatService: ChatService) {

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

    @PostMapping("/messages/{id}/read")
    fun markRead(@PathVariable id: String): ResponseEntity<ApiResponse<Unit>> {
        chatService.markMessageRead(id)
        return ResponseEntity.ok(ApiResponse.success(Unit, "Message marked as read"))
    }
}
