package com.acadyk.modules.chat.mapper

import com.acadyk.modules.chat.dto.ConversationResponse
import com.acadyk.modules.chat.dto.MessageDto
import com.acadyk.modules.chat.entity.ConversationEntity
import com.acadyk.modules.chat.entity.MessageEntity
import com.acadyk.modules.profiles.dto.ProfileResponse
import com.acadyk.modules.profiles.mapper.ProfileMapper
import org.springframework.stereotype.Component

@Component
class ChatMapper(private val profileMapper: ProfileMapper) {

    fun toDto(entity: MessageEntity): MessageDto {
        return MessageDto(
            id = entity.id.toString(),
            conversationId = entity.conversation.id.toString(),
            sender = profileMapper.toResponse(entity.sender),
            content = entity.content,
            messageType = entity.messageType,
            mediaUrl = entity.mediaUrl,
            isEdited = entity.isEdited,
            createdAt = entity.createdAt
        )
    }

    fun toResponse(
        entity: ConversationEntity,
        members: List<ProfileResponse> = emptyList(),
        unreadCount: Int = 0
    ): ConversationResponse {
        return ConversationResponse(
            id = entity.id.toString(),
            isGroup = entity.isGroup,
            title = entity.title,
            avatarUrl = entity.avatarUrl,
            lastMessageText = entity.lastMessageText,
            lastMessageAt = entity.lastMessageAt,
            unreadCount = unreadCount,
            members = members,
            createdAt = entity.createdAt
        )
    }
}
