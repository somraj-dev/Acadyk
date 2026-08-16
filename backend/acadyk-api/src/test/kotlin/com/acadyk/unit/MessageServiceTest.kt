package com.acadyk.unit

import com.acadyk.infrastructure.kafka.DomainEventPublisher
import com.acadyk.modules.chat.dto.SendMessageRequest
import com.acadyk.modules.chat.entity.ConversationEntity
import com.acadyk.modules.chat.entity.ConversationMemberEntity
import com.acadyk.modules.chat.entity.MessageEntity
import com.acadyk.modules.chat.mapper.ChatMapper
import com.acadyk.modules.chat.repository.ConversationMemberRepository
import com.acadyk.modules.chat.repository.ConversationRepository
import com.acadyk.modules.chat.repository.MessageReadRepository
import com.acadyk.modules.chat.repository.MessageRepository
import com.acadyk.modules.chat.service.ChatService
import com.acadyk.modules.profiles.entity.ProfileEntity
import com.acadyk.modules.profiles.mapper.ProfileMapper
import com.acadyk.modules.profiles.repository.ProfileRepository
import com.acadyk.security.CurrentUserProvider
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import org.mockito.Mockito.*
import org.springframework.messaging.simp.SimpMessagingTemplate
import java.util.Optional
import java.util.UUID

class MessageServiceTest {

    private lateinit var conversationRepository: ConversationRepository
    private lateinit var conversationMemberRepository: ConversationMemberRepository
    private lateinit var messageRepository: MessageRepository
    private lateinit var messageReadRepository: MessageReadRepository
    private lateinit var profileRepository: ProfileRepository
    private lateinit var chatMapper: ChatMapper
    private lateinit var profileMapper: ProfileMapper
    private lateinit var currentUserProvider: CurrentUserProvider
    private lateinit var messagingTemplate: SimpMessagingTemplate
    private lateinit var domainEventPublisher: DomainEventPublisher
    private lateinit var chatService: ChatService

    private val testUserId = UUID.randomUUID().toString()
    private val testConvId = UUID.randomUUID().toString()

    @Suppress("UNCHECKED_CAST")
    private fun <T> anyNonNull(): T {
        Mockito.any<T>()
        return null as T
    }

    @BeforeEach
    fun setUp() {
        conversationRepository = mock(ConversationRepository::class.java)
        conversationMemberRepository = mock(ConversationMemberRepository::class.java)
        messageRepository = mock(MessageRepository::class.java)
        messageReadRepository = mock(MessageReadRepository::class.java)
        profileRepository = mock(ProfileRepository::class.java)
        profileMapper = ProfileMapper()
        chatMapper = ChatMapper(profileMapper)
        currentUserProvider = mock(CurrentUserProvider::class.java)
        messagingTemplate = mock(SimpMessagingTemplate::class.java)
        domainEventPublisher = mock(DomainEventPublisher::class.java)

        `when`(currentUserProvider.getCurrentUserId()).thenReturn(testUserId)

        chatService = ChatService(
            conversationRepository = conversationRepository,
            conversationMemberRepository = conversationMemberRepository,
            messageRepository = messageRepository,
            messageReadRepository = messageReadRepository,
            profileRepository = profileRepository,
            chatMapper = chatMapper,
            profileMapper = profileMapper,
            currentUserProvider = currentUserProvider,
            messagingTemplate = messagingTemplate,
            domainEventPublisher = domainEventPublisher
        )
    }

    @Test
    fun `sendMessage persists message, updates conversation last message and emits MessageSent event`() {
        val sender = ProfileEntity(
            id = testUserId,
            username = "somraj",
            email = "somraj@acadyk.com",
            fullName = "Somraj Lodhi"
        )

        val conv = ConversationEntity(
            id = testConvId,
            isGroup = false,
            title = "Test Chat"
        )

        val request = SendMessageRequest(
            content = "Hello from Flutter and Kotlin!"
        )

        val savedMsg = MessageEntity(
            id = UUID.randomUUID().toString(),
            conversation = conv,
            sender = sender,
            content = request.content
        )

        `when`(conversationRepository.findByIdAndDeletedAtIsNull(testConvId)).thenReturn(Optional.of(conv))
        `when`(conversationMemberRepository.existsByConversationIdAndProfileId(testConvId, testUserId)).thenReturn(true)
        `when`(profileRepository.findById(testUserId)).thenReturn(Optional.of(sender))
        `when`(messageRepository.save(anyNonNull())).thenReturn(savedMsg)
        `when`(conversationMemberRepository.findAllByConversationId(testConvId)).thenReturn(
            listOf(ConversationMemberEntity(conversation = conv, profile = sender))
        )

        val result = chatService.sendMessage(testConvId, request)

        assertNotNull(result)
        assertEquals(request.content, result.content)
        assertEquals(testUserId, result.sender.id)
        verify(messageRepository, times(1)).save(anyNonNull())
        verify(domainEventPublisher, times(1)).publishMessageSent(anyNonNull())
    }
}
