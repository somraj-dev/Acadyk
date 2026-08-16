package com.acadyk.unit

import com.acadyk.infrastructure.kafka.DomainEventPublisher
import com.acadyk.infrastructure.redis.RedisDistributedLock
import com.acadyk.modules.opportunities.dto.CreateOpportunityRequest
import com.acadyk.modules.opportunities.entity.OpportunityEntity
import com.acadyk.modules.opportunities.mapper.OpportunityMapper
import com.acadyk.modules.opportunities.repository.OpportunityApplicationRepository
import com.acadyk.modules.opportunities.repository.OpportunityRepository
import com.acadyk.modules.opportunities.service.OpportunityService
import com.acadyk.modules.profiles.entity.ProfileEntity
import com.acadyk.modules.profiles.repository.ProfileRepository
import com.acadyk.modules.profiles.repository.ResumeRepository
import com.acadyk.security.CurrentUserProvider
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import org.mockito.Mockito.*
import org.springframework.data.redis.core.RedisTemplate
import org.springframework.data.redis.core.ValueOperations
import java.util.Optional
import java.util.UUID

class OpportunityServiceTest {

    private lateinit var opportunityRepository: OpportunityRepository
    private lateinit var applicationRepository: OpportunityApplicationRepository
    private lateinit var profileRepository: ProfileRepository
    private lateinit var resumeRepository: ResumeRepository
    private lateinit var opportunityMapper: OpportunityMapper
    private lateinit var currentUserProvider: CurrentUserProvider
    private lateinit var domainEventPublisher: DomainEventPublisher
    private lateinit var redisTemplate: RedisTemplate<String, Any>
    private lateinit var redisDistributedLock: RedisDistributedLock
    private lateinit var opportunityService: OpportunityService

    private val testUserId = UUID.randomUUID().toString()

    @Suppress("UNCHECKED_CAST")
    private fun <T> anyNonNull(): T {
        Mockito.any<T>()
        return null as T
    }

    @BeforeEach
    fun setUp() {
        opportunityRepository = mock(OpportunityRepository::class.java)
        applicationRepository = mock(OpportunityApplicationRepository::class.java)
        profileRepository = mock(ProfileRepository::class.java)
        resumeRepository = mock(ResumeRepository::class.java)
        opportunityMapper = OpportunityMapper()
        currentUserProvider = mock(CurrentUserProvider::class.java)
        domainEventPublisher = mock(DomainEventPublisher::class.java)

        @Suppress("UNCHECKED_CAST")
        redisTemplate = mock(RedisTemplate::class.java) as RedisTemplate<String, Any>
        @Suppress("UNCHECKED_CAST")
        val valueOps = mock(ValueOperations::class.java) as ValueOperations<String, Any>
        `when`(redisTemplate.opsForValue()).thenReturn(valueOps)
        `when`(valueOps.setIfAbsent(anyNonNull(), anyNonNull(), anyNonNull())).thenReturn(true)
        redisDistributedLock = RedisDistributedLock(redisTemplate)

        `when`(currentUserProvider.getCurrentUserId()).thenReturn(testUserId)

        opportunityService = OpportunityService(
            opportunityRepository = opportunityRepository,
            opportunityApplicationRepository = applicationRepository,
            profileRepository = profileRepository,
            resumeRepository = resumeRepository,
            opportunityMapper = opportunityMapper,
            currentUserProvider = currentUserProvider,
            domainEventPublisher = domainEventPublisher,
            redisDistributedLock = redisDistributedLock
        )
    }

    @Test
    fun `createOpportunity persists entity and emits OpportunityCreated event`() {
        val request = CreateOpportunityRequest(
            title = "Backend Engineer Intern",
            companyName = "Acadyk Labs",
            opportunityType = "INTERNSHIP",
            description = "Build scalable services with Spring Boot and Kafka",
            location = "Bangalore, India",
            isRemote = true,
            stipendOrSalary = "₹ 50,000/mo"
        )

        val poster = ProfileEntity(
            id = testUserId,
            username = "poster_user",
            fullName = "Somraj Lodhi",
            email = "somraj@acadyk.com"
        )

        val saved = OpportunityEntity(
            id = UUID.randomUUID().toString(),
            postedBy = poster,
            title = request.title,
            companyName = request.companyName,
            slug = "backend-engineer-intern-1234",
            opportunityType = request.opportunityType ?: "INTERNSHIP",
            description = request.description,
            location = request.location,
            isRemote = request.isRemote,
            stipendOrSalary = request.stipendOrSalary
        )

        `when`(profileRepository.findById(testUserId)).thenReturn(Optional.of(poster))
        `when`(opportunityRepository.save(anyNonNull())).thenReturn(saved)

        val result = opportunityService.createOpportunity(request)

        assertNotNull(result)
        assertEquals(request.title, result.title)
        assertEquals(request.companyName, result.companyName)
        verify(opportunityRepository, times(1)).save(anyNonNull())
        verify(domainEventPublisher, times(1)).publishOpportunityCreated(anyNonNull())
    }
}
