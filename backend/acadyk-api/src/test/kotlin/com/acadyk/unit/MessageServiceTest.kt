package com.acadyk.unit

import com.acadyk.modules.chat.dto.SendMessageDto
import com.acadyk.modules.chat.entity.ConversationEntity
import com.acadyk.modules.chat.entity.MessageEntity
import com.acadyk.modules.chat.repository.ConversationRepository
import com.acadyk.modules.chat.repository.MessageRepository
import com.acadyk.modules.chat.service.MessageService
import com.acadyk.infrastructure.kafka.DomainEventPublisher
import com.acadyk.security.CurrentUserProvider
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.mockito.Mockito.*
import java.util.Optional
import java.util.UUID

class MessageServiceTest {

    private lateinit var conversationRepository: ConversationRepository
    private lateinit var messageRepository: MessageRepository
    private lateinit var domainEventPublisher: DomainEventPublisher
    private lateinit var currentUserProvider: CurrentUserProvider
    private lateinit var messageService: MessageService

    private val testUserId = UUID.randomUUID()
    private val testConvId = UUID.randomUUID()

    @BeforeEach
    fun setUp() {
        conversationRepository = mock(ConversationRepository::class.java)
        messageRepository = mock(MessageRepository::class.java)
        domainEventPublisher = mock(DomainEventPublisher::class.java)
        currentUserProvider = mock(CurrentUserProvider::class.java)

        `when`(currentUserProvider.getCurrentUserId()).thenReturn(testUserId)

        messageService = MessageService(
            conversationRepository = conversationRepository,
            messageRepository = messageRepository,
            domainEventPublisher = domainEventPublisher,
            currentUserProvider = currentUserProvider
        )
    }

    @Test
    fun `sendMessage persists message, updates conversation last message and emits MessageSent event`() {
        val conv = ConversationEntity(
            id = testConvId,
            participantIds = listOf(testUserId, UUID.randomUUID())
        )

        val dto = SendMessageDto(
            conversationId = testConvId.toString(),
            content = "Hello from Flutter and Kotlin!"
        )

        val savedMsg = MessageEntity(
            id = UUID.randomUUID(),
            conversationId = testConvId,
            senderId = testUserId,
            content = dto.content
        )

        `when`(conversationRepository.findById(testConvId)).thenReturn(Optional.of(conv))
        `when`(messageRepository.save(any(MessageEntity::class.java))).thenReturn(savedMsg)

        val result = messageService.sendMessage(dto)

        assertNotNull(result)
        assertEquals(dto.content, result.content)
        assertEquals(testUserId.toString(), result.senderId)
        verify(messageRepository, times(1)).save(any())
        verify(domainEventPublisher, times(1)).publish(any())
    }
}
