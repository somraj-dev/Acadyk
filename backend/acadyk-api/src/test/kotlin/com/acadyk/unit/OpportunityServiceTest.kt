package com.acadyk.unit

import com.acadyk.modules.opportunities.dto.CreateOpportunityDto
import com.acadyk.modules.opportunities.entity.OpportunityEntity
import com.acadyk.modules.opportunities.entity.OpportunityType
import com.acadyk.modules.opportunities.repository.OpportunityRepository
import com.acadyk.modules.opportunities.repository.OpportunityApplicationRepository
import com.acadyk.modules.opportunities.service.OpportunityService
import com.acadyk.infrastructure.kafka.DomainEventPublisher
import com.acadyk.security.CurrentUserProvider
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.mockito.Mockito.*
import java.util.UUID

class OpportunityServiceTest {

    private lateinit var opportunityRepository: OpportunityRepository
    private lateinit var applicationRepository: OpportunityApplicationRepository
    private lateinit var domainEventPublisher: DomainEventPublisher
    private lateinit var currentUserProvider: CurrentUserProvider
    private lateinit var opportunityService: OpportunityService

    private val testUserId = UUID.randomUUID()

    @BeforeEach
    fun setUp() {
        opportunityRepository = mock(OpportunityRepository::class.java)
        applicationRepository = mock(OpportunityApplicationRepository::class.java)
        domainEventPublisher = mock(DomainEventPublisher::class.java)
        currentUserProvider = mock(CurrentUserProvider::class.java)

        `when`(currentUserProvider.getCurrentUserId()).thenReturn(testUserId)

        opportunityService = OpportunityService(
            opportunityRepository = opportunityRepository,
            applicationRepository = applicationRepository,
            domainEventPublisher = domainEventPublisher,
            currentUserProvider = currentUserProvider
        )
    }

    @Test
    fun `createOpportunity persists entity and emits OpportunityCreated event`() {
        val dto = CreateOpportunityDto(
            title = "Backend Engineer Intern",
            companyName = "Acadyk Labs",
            opportunityType = "INTERNSHIP",
            description = "Build scalable services with Spring Boot and Kafka",
            location = "Bangalore, India",
            isRemote = true,
            stipendOrSalary = "₹ 50,000/mo"
        )

        val saved = OpportunityEntity(
            id = UUID.randomUUID(),
            creatorId = testUserId,
            title = dto.title,
            companyName = dto.companyName,
            opportunityType = OpportunityType.INTERNSHIP,
            description = dto.description,
            location = dto.location,
            isRemote = dto.isRemote,
            stipendOrSalary = dto.stipendOrSalary
        )

        `when`(opportunityRepository.save(any(OpportunityEntity::class.java))).thenReturn(saved)

        val result = opportunityService.createOpportunity(dto)

        assertNotNull(result)
        assertEquals(dto.title, result.title)
        assertEquals(dto.companyName, result.companyName)
        verify(opportunityRepository, times(1)).save(any())
        verify(domainEventPublisher, times(1)).publish(any())
    }
}
