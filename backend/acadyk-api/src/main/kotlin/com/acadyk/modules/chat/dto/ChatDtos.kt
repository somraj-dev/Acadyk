package com.acadyk.modules.chat.dto

import com.acadyk.modules.profiles.dto.ProfileResponse
import jakarta.validation.constraints.NotBlank
import java.time.Instant

data class SendMessageRequest(
    @field:NotBlank(message = "Message content cannot be blank")
    val content: String,

    val messageType: String? = "TEXT",
    val mediaUrl: String? = null,

    // WhatsApp-style: Rich file attachment metadata
    val fileAttachment: FileAttachmentPayload? = null
)

/**
 * WhatsApp-style file attachment payload.
 * Sent alongside a message when sharing files/documents/images in a conversation.
 */
data class FileAttachmentPayload(
    val fileKey: String,              // S3 object key
    val fileUrl: String,              // Public or presigned download URL
    val fileName: String,             // Original filename (e.g., "thesis.pdf")
    val fileSizeBytes: Long,          // For display ("2.4 MB")
    val mimeType: String,             // "application/pdf", "image/png", etc.
    val thumbnailUrl: String? = null   // Auto-generated preview for images/PDFs
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
    val createdAt: Instant,

    // WhatsApp-style: File attachment metadata in response
    val fileName: String? = null,
    val fileSizeBytes: Long? = null,
    val mimeType: String? = null,
    val thumbnailUrl: String? = null
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

// --- WhatsApp-style real-time DTOs ---

/**
 * Payload for delivery/read receipt acknowledgement.
 * Sent from client → server when a message is delivered/read on the device.
 */
data class DeliveryReceiptPayload(
    val messageId: String,
    val status: String = "DELIVERED"  // DELIVERED or READ
)

/**
 * Payload for typing indicator events.
 * Fire-and-forget, NOT persisted.
 */
data class TypingIndicatorPayload(
    val userId: String,
    val userName: String,
    val isTyping: Boolean = true
)
