package com.acadyk

import org.junit.jupiter.api.Test
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.test.mock.mockito.MockBean
import org.springframework.kafka.core.KafkaTemplate
import org.springframework.test.context.ActiveProfiles

@SpringBootTest
@ActiveProfiles("dev")
class AcadykApplicationTests {

    @MockBean
    private lateinit var kafkaTemplate: KafkaTemplate<String, String>

    @Test
    fun contextLoads() {
        // Application context verification test
    }
}
