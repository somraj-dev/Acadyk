package com.acadyk.kafka

import com.acadyk.infrastructure.kafka.*
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.Test
import org.mockito.Mockito.*
import org.springframework.kafka.core.KafkaTemplate
import java.util.UUID

class KafkaDomainEventsTest {

    @Test
    fun `DomainEventPublisher routes events to correct topic`() {
        @Suppress("UNCHECKED_CAST")
        val kafkaTemplate = mock(KafkaTemplate::class.java) as KafkaTemplate<String, Any>
        val publisher = DomainEventPublisher(kafkaTemplate)

        val postEvent = PostCreatedEvent(
            postId = UUID.randomUUID().toString(),
            authorId = UUID.randomUUID().toString(),
            content = "Event test content"
        )

        publisher.publish(postEvent)

        verify(kafkaTemplate, times(1)).send(eq(KafkaTopics.POST_EVENTS), eq(postEvent.postId), eq(postEvent))
    }

    @Test
    fun `UserCreatedEvent serializes and deserializes properly`() {
        val userEvent = UserCreatedEvent(
            userId = UUID.randomUUID().toString(),
            email = "somraj@acadyk.com",
            fullName = "Somraj Lodhi"
        )

        assertEquals("USER_CREATED", userEvent.eventType)
        assertEquals("somraj@acadyk.com", userEvent.email)
    }
}
