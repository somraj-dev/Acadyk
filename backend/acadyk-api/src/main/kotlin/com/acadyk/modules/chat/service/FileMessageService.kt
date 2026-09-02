package com.acadyk.modules.chat.service

import com.acadyk.common.BadRequestException
import com.acadyk.common.ForbiddenException
import com.acadyk.common.ResourceNotFoundException
import com.acadyk.infrastructure.kafka.DomainEventPublisher
import com.acadyk.infrastructure.kafka.MessageSentEvent
import com.acadyk.infrastructure.s3.S3StorageService
import com.acadyk.modules.chat.dto.FileAttachmentPayload
import com.acadyk.modules.chat.dto.MessageDto
import com.acadyk.modules.chat.dto.SendMessageRequest
import com.acadyk.modules.chat.entity.MessageEntity
import com.acadyk.modules.chat.mapper.ChatMapper
import com.acadyk.modules.chat.repository.ConversationMemberRepository
import com.acadyk.modules.chat.repository.ConversationRepository
import com.acadyk.modules.chat.repository.MessageRepository
import com.acadyk.modules.profiles.repository.ProfileRepository
import com.acadyk.security.CurrentUserProvider
import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.messaging.simp.SimpMessagingTemplate
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import org.springframework.web.multipart.MultipartFile
import java.util.UUID

/**
 * WhatsApp-style file sharing service for conversations.
 *
 * Architecture: Real-time pipeline (WhatsApp Channel)
 * Flow: Upload S3 → Persist in PostgreSQL → WebSocket STOMP broadcast → Kafka for offline FCM push
 *
 * This service is intentionally separate from the generic FileService (which handles
 * context-free uploads) because conversation file sharing requires:
 * 1. Conversation membership authorization
 * 2. Real-time WebSocket delivery to online recipients
 * 3. File metadata embedded in the message entity (not just a URL)
 * 4. Kafka event for offline FCM push notifications
 */
@Service
@Transactional
class FileMessageService(
    private val conversationRepository: ConversationRepository,
    private val conversationMemberRepository: ConversationMemberRepository,
    private val messageRepository: MessageRepository,
    private val profileRepository: ProfileRepository,
    private val chatMapper: ChatMapper,
    private val currentUserProvider: CurrentUserProvider,
    private val messagingTemplate: SimpMessagingTemplate,
    private val domainEventPublisher: DomainEventPublisher,
    private val s3StorageService: S3StorageService,
    @Value("\${aws.s3.bucket:acadyk-media-production}") private val bucketName: String
) {
    private val logger = LoggerFactory.getLogger(javaClass)

    companion object {
        const val MAX_CHAT_FILE_SIZE_BYTES = 25 * 1024 * 1024L // 25 MB for chat files
        val ALLOWED_CHAT_EXTENSIONS = setOf(
            "jpg", "jpeg", "png", "webp", "gif",           // Images
            "pdf", "doc", "docx", "xls", "xlsx", "ppt", "pptx", // Documents
            "txt", "csv",                                    // Text files
            "mp4", "mov",                                    // Videos
            "mp3", "aac"                                     // Audio
        )
        val ALLOWED_CHAT_MIME_TYPES = setOf(
            "image/jpeg", "image/png", "image/webp", "image/gif",
            "application/pdf",
            "application/msword",
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            "application/vnd.ms-excel",
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            "application/vnd.ms-powerpoint",
            "application/vnd.openxmlformats-officedocument.presentationml.presentation",
            "text/plain", "text/csv",
            "video/mp4", "video/quicktime",
            "audio/mpeg", "audio/aac"
        )
    }

    /**
     * WhatsApp-style multipart file upload within a conversation.
     *
     * Pipeline:
     * 1. Validate file (size, type, extension)
     * 2. Verify sender is a conversation member
     * 3. Upload to S3 under conversation-scoped path
     * 4. Persist message with full file metadata in PostgreSQL
     * 5. Broadcast instantly via WebSocket STOMP to online recipients
     * 6. Publish MessageSentEvent to Kafka for offline FCM push
     */
    fun shareFileInConversation(conversationId: UUID, file: MultipartFile): MessageDto {
        // Validate file
        if (file.isEmpty) {
            throw BadRequestException("File cannot be empty")
        }
        if (file.size > MAX_CHAT_FILE_SIZE_BYTES) {
            throw BadRequestException("File size (${file.size / (1024 * 1024)} MB) exceeds maximum allowed size of 25 MB for chat")
        }

        val originalFilename = file.originalFilename ?: "attachment.bin"
        val ext = originalFilename.substringAfterLast('.', "bin").lowercase()
        if (ext !in ALLOWED_CHAT_EXTENSIONS) {
            throw BadRequestException("File type '.$ext' is not supported for chat sharing")
        }

        val contentType = file.contentType ?: "application/octet-stream"
        if (contentType.lowercase() !in ALLOWED_CHAT_MIME_TYPES) {
            throw BadRequestException("MIME type '$contentType' is not supported for chat sharing")
        }

        // Auth: Verify conversation membership
        val currentUserId = currentUserProvider.getCurrentUserId()
        val conversation = conversationRepository.findByIdAndDeletedAtIsNull(conversationId)
            .orElseThrow { ResourceNotFoundException("Conversation not found") }

        if (!conversationMemberRepository.existsByConversationIdAndProfileId(conversationId, currentUserId)) {
            throw ForbiddenException("You are not a participant in this conversation")
        }

        val sender = profileRepository.findById(currentUserId)
            .orElseThrow { ResourceNotFoundException("User profile not found") }

        // Upload to S3 under conversation-scoped path
        val fileKey = "chat/$conversationId/${UUID.randomUUID()}.$ext"
        val fileUrl = s3StorageService.uploadFile(
            key = fileKey,
            inputStream = file.inputStream,
            contentLength = file.size,
            contentType = contentType,
            bucket = bucketName
        )

        // Determine message type from MIME
        val messageType = resolveMessageType(contentType)

        // Persist message with full file metadata (PostgreSQL — Source of Truth)
        val messageEntity = MessageEntity(
            conversation = conversation,
            sender = sender,
            content = originalFilename, // Content shows filename for file messages
            messageType = messageType,
            mediaUrl = fileUrl,
            fileName = originalFilename,
            fileSizeBytes = file.size,
            mimeType = contentType,
            thumbnailUrl = null // Thumbnail generation can be added later
        )
        val savedMessage = messageRepository.save(messageEntity)

        // Update conversation's last message
        conversation.lastMessageText = "📎 $originalFilename"
        conversation.lastMessageAt = savedMessage.createdAt
        conversationRepository.save(conversation)

        val messageDto = chatMapper.toDto(savedMessage)

        // Broadcast instantly via WebSocket STOMP (WhatsApp-style real-time delivery)
        try {
            messagingTemplate.convertAndSend("/topic/conversations/$conversationId", messageDto)
        } catch (e: Exception) {
            logger.warn("WebSocket broadcast failed for file message in conversation $conversationId: ${e.message}")
        }

        // Publish MessageSentEvent to Kafka for offline FCM push
        val memberIds = conversationMemberRepository.findAllByConversationId(conversationId)
            .map { it.profile.id.toString() }
        domainEventPublisher.publishMessageSent(
            MessageSentEvent(
                messageId = savedMessage.id.toString(),
                conversationId = conversationId.toString(),
                senderId = sender.id.toString(),
                senderName = sender.fullName,
                contentSnippet = "📎 $originalFilename",
                recipientIds = memberIds
            )
        )

        logger.info("File message shared in conversation $conversationId: $originalFilename ($messageType, ${file.size} bytes)")
        return messageDto
    }

    /**
     * WhatsApp-style file sharing using a presigned URL (client already uploaded to S3).
     * Used when the client uploads directly to S3 via presigned URL, then notifies the server.
     */
    fun sharePresignedFileInConversation(conversationId: UUID, attachment: FileAttachmentPayload): MessageDto {
        // Auth: Verify conversation membership
        val currentUserId = currentUserProvider.getCurrentUserId()
        val conversation = conversationRepository.findByIdAndDeletedAtIsNull(conversationId)
            .orElseThrow { ResourceNotFoundException("Conversation not found") }

        if (!conversationMemberRepository.existsByConversationIdAndProfileId(conversationId, currentUserId)) {
            throw ForbiddenException("You are not a participant in this conversation")
        }

        val sender = profileRepository.findById(currentUserId)
            .orElseThrow { ResourceNotFoundException("User profile not found") }

        val messageType = resolveMessageType(attachment.mimeType)

        // Persist message with full file metadata (PostgreSQL — Source of Truth)
        val messageEntity = MessageEntity(
            conversation = conversation,
            sender = sender,
            content = attachment.fileName,
            messageType = messageType,
            mediaUrl = attachment.fileUrl,
            fileName = attachment.fileName,
            fileSizeBytes = attachment.fileSizeBytes,
            mimeType = attachment.mimeType,
            thumbnailUrl = attachment.thumbnailUrl
        )
        val savedMessage = messageRepository.save(messageEntity)

        conversation.lastMessageText = "📎 ${attachment.fileName}"
        conversation.lastMessageAt = savedMessage.createdAt
        conversationRepository.save(conversation)

        val messageDto = chatMapper.toDto(savedMessage)

        // Broadcast instantly via WebSocket STOMP
        try {
            messagingTemplate.convertAndSend("/topic/conversations/$conversationId", messageDto)
        } catch (e: Exception) {
            logger.warn("WebSocket broadcast failed for presigned file message in conversation $conversationId: ${e.message}")
        }

        // Publish to Kafka for offline FCM push
        val memberIds = conversationMemberRepository.findAllByConversationId(conversationId)
            .map { it.profile.id.toString() }
        domainEventPublisher.publishMessageSent(
            MessageSentEvent(
                messageId = savedMessage.id.toString(),
                conversationId = conversationId.toString(),
                senderId = sender.id.toString(),
                senderName = sender.fullName,
                contentSnippet = "📎 ${attachment.fileName}",
                recipientIds = memberIds
            )
        )

        logger.info("Presigned file message shared in conversation $conversationId: ${attachment.fileName}")
        return messageDto
    }

    /**
     * Resolve the message type from MIME type for proper client rendering.
     */
    private fun resolveMessageType(mimeType: String): String {
        return when {
            mimeType.startsWith("image/") -> "IMAGE"
            mimeType.startsWith("video/") -> "VIDEO"
            mimeType.startsWith("audio/") -> "AUDIO"
            mimeType == "application/pdf" ||
            mimeType.contains("document") ||
            mimeType.contains("spreadsheet") ||
            mimeType.contains("presentation") ||
            mimeType.startsWith("text/") -> "DOCUMENT"
            else -> "FILE"
        }
    }
}
