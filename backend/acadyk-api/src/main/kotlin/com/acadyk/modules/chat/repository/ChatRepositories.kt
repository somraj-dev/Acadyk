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

@Repository
interface ConversationRepository : JpaRepository<ConversationEntity, String> {
    fun findByIdAndDeletedAtIsNull(id: String): Optional<ConversationEntity>
}

@Repository
interface ConversationMemberRepository : JpaRepository<ConversationMemberEntity, String> {
    fun findAllByProfileId(profileId: String): List<ConversationMemberEntity>
    fun findAllByConversationId(conversationId: String): List<ConversationMemberEntity>
    fun findByConversationIdAndProfileId(conversationId: String, profileId: String): Optional<ConversationMemberEntity>
    fun existsByConversationIdAndProfileId(conversationId: String, profileId: String): Boolean
}

@Repository
interface MessageRepository : JpaRepository<MessageEntity, String> {
    fun findAllByConversationIdAndDeletedAtIsNullOrderByCreatedAtDesc(conversationId: String, pageable: Pageable): Page<MessageEntity>
    fun findAllByConversationIdAndDeletedAtIsNullOrderByCreatedAtAsc(conversationId: String): List<MessageEntity>
}

@Repository
interface MessageReadRepository : JpaRepository<MessageReadEntity, String> {
    fun existsByMessageIdAndProfileId(messageId: String, profileId: String): Boolean
}
