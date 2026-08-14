package com.acadyk.modules.chat.dto

import com.acadyk.modules.profiles.dto.ProfileResponse
import jakarta.validation.constraints.NotBlank
import java.time.Instant

data class SendMessageRequest(
    @field:NotBlank(message = "Message content cannot be blank")
    val content: String,

    val messageType: String? = "TEXT",
    val mediaUrl: String? = null
)

data class StartDirectMessageRequest(
    val recipientId: String,
    val initialMessage: String? = null
)

data class MessageDto(
    val id: String,
    val conversationId: String,
    val sender: ProfileResponse,
    val content: String,
    val messageType: String,
    val mediaUrl: String?,
    val isEdited: Boolean,
    val createdAt: Instant
)

data class ConversationResponse(
    val id: String,
    val isGroup: Boolean,
    val title: String?,
    val avatarUrl: String?,
    val lastMessageText: String?,
    val lastMessageAt: Instant,
    val unreadCount: Int = 0,
    val members: List<ProfileResponse> = emptyList(),
    val createdAt: Instant
)
