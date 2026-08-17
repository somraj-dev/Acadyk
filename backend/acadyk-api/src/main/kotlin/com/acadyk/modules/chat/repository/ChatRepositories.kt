package com.acadyk.modules.chat.repository

import com.acadyk.modules.chat.entity.ConversationEntity
import com.acadyk.modules.chat.entity.ConversationMemberEntity
import com.acadyk.modules.chat.entity.MessageEntity
import com.acadyk.modules.chat.entity.MessageReadEntity
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.Optional
import java.util.UUID

@Repository
interface ConversationRepository : JpaRepository<ConversationEntity, UUID> {
    fun findByIdAndDeletedAtIsNull(id: UUID): Optional<ConversationEntity>
}

@Repository
interface ConversationMemberRepository : JpaRepository<ConversationMemberEntity, UUID> {
    fun findAllByProfileId(profileId: UUID): List<ConversationMemberEntity>
    fun findAllByConversationId(conversationId: UUID): List<ConversationMemberEntity>
    fun findByConversationIdAndProfileId(conversationId: UUID, profileId: UUID): Optional<ConversationMemberEntity>
    fun existsByConversationIdAndProfileId(conversationId: UUID, profileId: UUID): Boolean
}

@Repository
interface MessageRepository : JpaRepository<MessageEntity, UUID> {
    fun findAllByConversationIdAndDeletedAtIsNullOrderByCreatedAtDesc(conversationId: UUID, pageable: Pageable): Page<MessageEntity>
    fun findAllByConversationIdAndDeletedAtIsNullOrderByCreatedAtAsc(conversationId: UUID): List<MessageEntity>
}

@Repository
interface MessageReadRepository : JpaRepository<MessageReadEntity, UUID> {
    fun existsByMessageIdAndProfileId(messageId: UUID, profileId: UUID): Boolean
}
