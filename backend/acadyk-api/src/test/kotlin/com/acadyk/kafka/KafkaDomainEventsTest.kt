package com.acadyk.kafka

import com.acadyk.infrastructure.kafka.*
import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule
import com.fasterxml.jackson.module.kotlin.registerKotlinModule
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.Test
import org.mockito.Mockito.*
import org.springframework.kafka.core.KafkaTemplate
import java.util.UUID

class KafkaDomainEventsTest {

    @Test
    fun `DomainEventPublisher routes events to correct topic`() {
        @Suppress("UNCHECKED_CAST")
        val kafkaTemplate = mock(KafkaTemplate::class.java) as KafkaTemplate<String, String>
        val objectMapper = ObjectMapper().registerKotlinModule().registerModule(JavaTimeModule())
        val publisher = DomainEventPublisher(kafkaTemplate, objectMapper)

        val postEvent = PostCreatedEvent(
            postId = UUID.randomUUID().toString(),
            authorId = UUID.randomUUID().toString(),
            contentSnippet = "Event test content",
            postType = "text"
        )

        publisher.publishPostCreated(postEvent)

        verify(kafkaTemplate, times(1)).send(eq("acadyk.posts"), eq(postEvent.postId), anyString())
    }

    @Test
    fun `UserCreatedEvent serializes and deserializes properly`() {
        val userEvent = UserCreatedEvent(
            userId = UUID.randomUUID().toString(),
            email = "somraj@acadyk.com",
            role = "STUDENT"
        )

        assertEquals("UserCreated", userEvent.eventType)
        assertEquals("somraj@acadyk.com", userEvent.email)
        assertEquals("STUDENT", userEvent.role)
    }
}
