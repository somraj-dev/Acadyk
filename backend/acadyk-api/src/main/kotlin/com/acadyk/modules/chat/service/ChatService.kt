package com.acadyk.modules.chat.service

import com.acadyk.common.ForbiddenException
import com.acadyk.common.PageResponse
import com.acadyk.common.ResourceNotFoundException
import com.acadyk.common.toUUID
import com.acadyk.infrastructure.kafka.DomainEventPublisher
import com.acadyk.infrastructure.kafka.MessageSentEvent
import com.acadyk.modules.chat.dto.ConversationResponse
import com.acadyk.modules.chat.dto.MessageDto
import com.acadyk.modules.chat.dto.SendMessageRequest
import com.acadyk.modules.chat.dto.StartDirectMessageRequest
import com.acadyk.modules.chat.entity.ConversationEntity
import com.acadyk.modules.chat.entity.ConversationMemberEntity
import com.acadyk.modules.chat.entity.MessageEntity
import com.acadyk.modules.chat.entity.MessageReadEntity
import com.acadyk.modules.chat.mapper.ChatMapper
import com.acadyk.modules.chat.repository.ConversationMemberRepository
import com.acadyk.modules.chat.repository.ConversationRepository
import com.acadyk.modules.chat.repository.MessageReadRepository
import com.acadyk.modules.chat.repository.MessageRepository
import com.acadyk.modules.profiles.mapper.ProfileMapper
import com.acadyk.modules.profiles.repository.ProfileRepository
import com.acadyk.security.CurrentUserProvider
import org.springframework.data.domain.PageRequest
import org.springframework.messaging.simp.SimpMessagingTemplate
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

@Service
@Transactional
class ChatService(
    private val conversationRepository: ConversationRepository,
    private val conversationMemberRepository: ConversationMemberRepository,
    private val messageRepository: MessageRepository,
    private val messageReadRepository: MessageReadRepository,
    private val profileRepository: ProfileRepository,
    private val chatMapper: ChatMapper,
    private val profileMapper: ProfileMapper,
    private val currentUserProvider: CurrentUserProvider,
    private val messagingTemplate: SimpMessagingTemplate,
    private val domainEventPublisher: DomainEventPublisher
) {

    @Transactional(readOnly = true)
    fun getMyConversations(): List<ConversationResponse> {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val memberships = conversationMemberRepository.findAllByProfileId(currentUserId)

        return memberships.map { member ->
            val conv = member.conversation
            val allMembers = conversationMemberRepository.findAllByConversationId(conv.id)
                .map { profileMapper.toResponse(it.profile) }
            chatMapper.toResponse(conv, allMembers, 0)
        }.sortedByDescending { it.lastMessageAt }
    }

    @Transactional(readOnly = true)
    fun getMessages(conversationId: UUID, page: Int, size: Int): PageResponse<MessageDto> {
        val currentUserId = currentUserProvider.getCurrentUserId()
        if (!conversationMemberRepository.existsByConversationIdAndProfileId(conversationId, currentUserId)) {
            throw ForbiddenException("You are not a participant in this conversation")
        }

        val pageable = PageRequest.of(page, size)
        val messagesPage = messageRepository.findAllByConversationIdAndDeletedAtIsNullOrderByCreatedAtDesc(conversationId, pageable)
        return PageResponse.from(messagesPage, chatMapper::toDto)
    }

    @Transactional(readOnly = true)
    fun getMessages(conversationId: String, page: Int, size: Int): PageResponse<MessageDto> =
        getMessages(conversationId.toUUID(), page, size)

    fun sendMessage(conversationId: UUID, request: SendMessageRequest): MessageDto {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val conv = conversationRepository.findByIdAndDeletedAtIsNull(conversationId)
            .orElseThrow { ResourceNotFoundException("Conversation not found") }

        if (!conversationMemberRepository.existsByConversationIdAndProfileId(conversationId, currentUserId)) {
            throw ForbiddenException("You are not a participant in this conversation")
        }

        val sender = profileRepository.findById(currentUserId)
            .orElseThrow { ResourceNotFoundException("User profile not found") }

        // Determine message type: if file attachment is present, use file-based type
        val effectiveMessageType = if (request.fileAttachment != null) {
            resolveMessageTypeFromMime(request.fileAttachment.mimeType)
        } else {
            request.messageType ?: "TEXT"
        }

        // 1. PostgreSQL Persistence FIRST (Source of Truth)
        val message = MessageEntity(
            conversation = conv,
            sender = sender,
            content = request.content,
            messageType = effectiveMessageType,
            mediaUrl = request.fileAttachment?.fileUrl ?: request.mediaUrl,
            // WhatsApp-style: Populate file metadata if attachment is present
            fileName = request.fileAttachment?.fileName,
            fileSizeBytes = request.fileAttachment?.fileSizeBytes,
            mimeType = request.fileAttachment?.mimeType,
            thumbnailUrl = request.fileAttachment?.thumbnailUrl
        )
        val saved = messageRepository.save(message)

        val lastMsgText = if (request.fileAttachment != null) {
            "📎 ${request.fileAttachment.fileName}"
        } else {
            request.content
        }
        conv.lastMessageText = lastMsgText
        conv.lastMessageAt = saved.createdAt
        conversationRepository.save(conv)

        val dto = chatMapper.toDto(saved)

        // 2. Realtime WebSocket broadcast (WhatsApp-style instant delivery)
        try {
            messagingTemplate.convertAndSend("/topic/conversations/$conversationId", dto)
        } catch (_: Exception) {}

        // 3. Asynchronous Kafka event (for offline FCM push)
        val memberIds = conversationMemberRepository.findAllByConversationId(conversationId).map { it.profile.id.toString() }
        domainEventPublisher.publishMessageSent(
            MessageSentEvent(
                messageId = saved.id.toString(),
                conversationId = conversationId.toString(),
                senderId = sender.id.toString(),
                senderName = sender.fullName,
                contentSnippet = payloadToSnippet(lastMsgText),
                recipientIds = memberIds
            )
        )

        return dto
    }

    fun sendMessage(conversationId: String, request: SendMessageRequest): MessageDto =
        sendMessage(conversationId.toUUID(), request)

    private fun payloadToSnippet(content: String): String = if (content.length > 100) content.take(97) + "..." else content

    private fun resolveMessageTypeFromMime(mimeType: String): String {
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

    fun startDirectMessage(request: StartDirectMessageRequest): ConversationResponse {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val recipientUuid = request.recipientId.toUUID()
        val currentUser = profileRepository.findById(currentUserId)
            .orElseThrow { ResourceNotFoundException("Current user profile not found") }
        val recipient = profileRepository.findById(recipientUuid)
            .orElseThrow { ResourceNotFoundException("Recipient profile not found") }

        val conv = conversationRepository.save(
            ConversationEntity(
                isGroup = false,
                title = recipient.fullName,
                avatarUrl = recipient.profilePhotoUrl
            )
        )

        conversationMemberRepository.save(ConversationMemberEntity(conversation = conv, profile = currentUser))
        conversationMemberRepository.save(ConversationMemberEntity(conversation = conv, profile = recipient))

        if (!request.initialMessage.isNullOrBlank()) {
            sendMessage(conv.id, SendMessageRequest(content = request.initialMessage))
        }

        val members = listOf(profileMapper.toResponse(currentUser), profileMapper.toResponse(recipient))
        return chatMapper.toResponse(conv, members, 0)
    }

    fun markMessageRead(messageId: UUID) {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val message = messageRepository.findById(messageId).orElse(null) ?: return
        val profile = profileRepository.findById(currentUserId).orElse(null) ?: return

        if (!messageReadRepository.existsByMessageIdAndProfileId(messageId, currentUserId)) {
            messageReadRepository.save(MessageReadEntity(message = message, profile = profile))
        }
    }

    fun markMessageRead(messageId: String) = markMessageRead(messageId.toUUID())
}
