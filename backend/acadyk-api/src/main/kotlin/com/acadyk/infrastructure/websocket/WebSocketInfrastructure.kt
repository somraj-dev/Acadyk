package com.acadyk.infrastructure.websocket

import com.acadyk.common.toUUIDOrNull
import com.acadyk.infrastructure.kafka.DomainEventPublisher
import com.acadyk.infrastructure.kafka.MessageSentEvent
import com.acadyk.modules.chat.dto.SendMessageRequest
import com.acadyk.modules.chat.entity.MessageEntity
import com.acadyk.modules.chat.mapper.ChatMapper
import com.acadyk.modules.chat.repository.ConversationMemberRepository
import com.acadyk.modules.chat.repository.ConversationRepository
import com.acadyk.modules.chat.repository.MessageRepository
import com.acadyk.modules.profiles.repository.ProfileRepository
import com.acadyk.security.FirebaseTokenVerifier
import com.acadyk.security.UserPrincipal
import org.slf4j.LoggerFactory
import org.springframework.context.annotation.Configuration
import org.springframework.messaging.Message
import org.springframework.messaging.MessageChannel
import org.springframework.messaging.handler.annotation.DestinationVariable
import org.springframework.messaging.handler.annotation.MessageMapping
import org.springframework.messaging.handler.annotation.Payload
import org.springframework.messaging.simp.SimpMessagingTemplate
import org.springframework.messaging.simp.config.ChannelRegistration
import org.springframework.messaging.simp.config.MessageBrokerRegistry
import org.springframework.messaging.simp.stomp.StompCommand
import org.springframework.messaging.simp.stomp.StompHeaderAccessor
import org.springframework.messaging.support.ChannelInterceptor
import org.springframework.messaging.support.MessageHeaderAccessor
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.stereotype.Component
import org.springframework.stereotype.Controller
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker
import org.springframework.web.socket.config.annotation.StompEndpointRegistry
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer
import java.security.Principal
import java.util.UUID

@Configuration
@EnableWebSocketMessageBroker
class WebSocketConfig(
    private val webSocketAuthInterceptor: WebSocketAuthInterceptor
) : WebSocketMessageBrokerConfigurer {

    override fun configureMessageBroker(registry: MessageBrokerRegistry) {
        // Prefix for topics to which clients subscribe
        registry.enableSimpleBroker("/topic", "/queue")
        // Prefix for messages routed to @MessageMapping methods
        registry.setApplicationDestinationPrefixes("/app")
        // Prefix for user-specific queues
        registry.setUserDestinationPrefix("/user")
    }

    override fun registerStompEndpoints(registry: StompEndpointRegistry) {
        registry.addEndpoint("/ws")
            .setAllowedOriginPatterns("*")
        registry.addEndpoint("/ws")
            .setAllowedOriginPatterns("*")
            .withSockJS()
    }

    override fun configureClientInboundChannel(registration: ChannelRegistration) {
        registration.interceptors(webSocketAuthInterceptor)
    }
}

/**
 * WebSocket Authentication Interceptor.
 * Validates the Firebase/JWT token during the STOMP CONNECT frame.
 */
@Component
class WebSocketAuthInterceptor(
    private val tokenVerifier: FirebaseTokenVerifier,
    private val profileRepository: ProfileRepository,
    private val userRepository: com.acadyk.modules.users.repository.UserRepository
) : ChannelInterceptor {

    private val logger = LoggerFactory.getLogger(javaClass)

    override fun preSend(message: Message<*>, channel: MessageChannel): Message<*> {
        val accessor = MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor::class.java)

        if (accessor != null && StompCommand.CONNECT == accessor.command) {
            val authHeader = accessor.getFirstNativeHeader("Authorization")
                ?: accessor.getFirstNativeHeader("token")

            if (!authHeader.isNullOrBlank()) {
                val token = if (authHeader.startsWith("Bearer ")) authHeader.substring(7) else authHeader
                val verifiedUser = tokenVerifier.verifyToken(token)

                if (verifiedUser != null) {
                    val profile = verifiedUser.uid.toUUIDOrNull()?.let { profileRepository.findById(it).orElse(null) }
                        ?: userRepository.findByEmail(verifiedUser.email).flatMap { profileRepository.findById(it.id) }.orElse(null)
                    val principal = UserPrincipal(
                        id = profile?.id ?: UUID.nameUUIDFromBytes(verifiedUser.uid.toByteArray()),
                        email = verifiedUser.email,
                        username = profile?.username ?: verifiedUser.email.substringBefore("@")
                    )
                    val auth = UsernamePasswordAuthenticationToken(principal, null, principal.authorities)
                    accessor.user = auth
                    logger.debug("WebSocket authenticated for user: ${principal.id}")
                }
            }
        }
        return message
    }
}

/**
 * Realtime Chat Controller for incoming STOMP messages.
 * Flow: Flutter -> WS -> Auth -> Validation -> PostgreSQL -> Kafka -> STOMP Broadcast
 */
@Controller
class RealtimeChatController(
    private val conversationRepository: ConversationRepository,
    private val conversationMemberRepository: ConversationMemberRepository,
    private val messageRepository: MessageRepository,
    private val profileRepository: ProfileRepository,
    private val chatMapper: ChatMapper,
    private val messagingTemplate: SimpMessagingTemplate,
    private val domainEventPublisher: DomainEventPublisher
) {
    private val logger = LoggerFactory.getLogger(javaClass)

    @MessageMapping("/chat.send/{conversationId}")
    fun handleRealtimeMessage(
        @DestinationVariable conversationId: String,
        @Payload payload: SendMessageRequest,
        principal: Principal?
    ) {
        val senderId = principal?.name ?: "anonymous"
        if (payload.content.isBlank()) return

        val convUuid = conversationId.toUUIDOrNull() ?: return
        val senderUuid = senderId.toUUIDOrNull() ?: return

        val conversation = conversationRepository.findByIdAndDeletedAtIsNull(convUuid).orElse(null) ?: return
        val sender = profileRepository.findById(senderUuid).orElse(null) ?: return

        // 1. Persist message in PostgreSQL FIRST (Source of Truth)
        val messageEntity = MessageEntity(
            conversation = conversation,
            sender = sender,
            content = payload.content,
            messageType = payload.messageType ?: "TEXT",
            mediaUrl = payload.mediaUrl
        )
        val savedMessage = messageRepository.save(messageEntity)

        conversation.lastMessageText = payload.content
        conversation.lastMessageAt = savedMessage.createdAt
        conversationRepository.save(conversation)

        val messageDto = chatMapper.toDto(savedMessage)

        // 2. Broadcast immediately over WebSocket topic to connected recipients
        messagingTemplate.convertAndSend("/topic/conversations/$conversationId", messageDto)

        // 3. Publish asynchronous MessageSentEvent to Kafka for offline push notifications
        val memberIds = conversationMemberRepository.findAllByConversationId(convUuid).map { it.profile.id.toString() }
        domainEventPublisher.publishMessageSent(
            MessageSentEvent(
                messageId = savedMessage.id.toString(),
                conversationId = conversationId,
                senderId = sender.id.toString(),
                senderName = sender.fullName,
                contentSnippet = payload.content,
                recipientIds = memberIds
            )
        )

        logger.debug("Realtime message sent and broadcast for conversation: $conversationId")
    }
}
