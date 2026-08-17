package com.acadyk

import com.acadyk.modules.search.repository.*
import org.junit.jupiter.api.Test
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.test.mock.mockito.MockBean
import org.springframework.data.elasticsearch.core.ElasticsearchOperations
import org.springframework.kafka.core.KafkaTemplate
import org.springframework.test.context.ActiveProfiles

@SpringBootTest
@ActiveProfiles("dev")
class AcadykApplicationTests {

    @MockBean
    private lateinit var profileSearchRepository: ProfileSearchRepository

    @MockBean
    private lateinit var postSearchRepository: PostSearchRepository

    @MockBean
    private lateinit var opportunitySearchRepository: OpportunitySearchRepository

    @MockBean
    private lateinit var eventSearchRepository: EventSearchRepository

    @MockBean
    private lateinit var communitySearchRepository: CommunitySearchRepository

    @MockBean
    private lateinit var startupSearchRepository: StartupSearchRepository

    @MockBean
    private lateinit var companySearchRepository: CompanySearchRepository

    @MockBean
    private lateinit var elasticsearchOperations: ElasticsearchOperations

    @MockBean
    private lateinit var kafkaTemplate: KafkaTemplate<String, String>

    @Test
    fun contextLoads() {
        // Application context verification test
    }
}
