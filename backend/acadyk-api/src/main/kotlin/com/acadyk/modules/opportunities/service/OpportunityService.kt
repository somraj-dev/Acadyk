package com.acadyk.modules.opportunities.service

import com.acadyk.common.PageResponse
import com.acadyk.common.ResourceNotFoundException
import com.acadyk.infrastructure.kafka.ApplicationSubmittedEvent
import com.acadyk.infrastructure.kafka.DomainEventPublisher
import com.acadyk.infrastructure.kafka.OpportunityCreatedEvent
import com.acadyk.infrastructure.redis.RedisDistributedLock
import com.acadyk.modules.opportunities.dto.ApplyOpportunityRequest
import com.acadyk.modules.opportunities.dto.CreateOpportunityRequest
import com.acadyk.modules.opportunities.dto.OpportunityResponse
import com.acadyk.modules.opportunities.entity.OpportunityApplicationEntity
import com.acadyk.modules.opportunities.entity.OpportunityEntity
import com.acadyk.modules.opportunities.mapper.OpportunityMapper
import com.acadyk.modules.opportunities.repository.OpportunityApplicationRepository
import com.acadyk.modules.opportunities.repository.OpportunityRepository
import com.acadyk.modules.profiles.repository.ProfileRepository
import com.acadyk.modules.profiles.repository.ResumeRepository
import com.acadyk.security.CurrentUserProvider
import org.springframework.data.domain.PageRequest
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@Transactional
class OpportunityService(
    private val opportunityRepository: OpportunityRepository,
    private val opportunityApplicationRepository: OpportunityApplicationRepository,
    private val profileRepository: ProfileRepository,
    private val resumeRepository: ResumeRepository,
    private val opportunityMapper: OpportunityMapper,
    private val currentUserProvider: CurrentUserProvider,
    private val domainEventPublisher: DomainEventPublisher,
    private val redisDistributedLock: RedisDistributedLock
) {

    @Transactional(readOnly = true)
    fun getOpportunities(type: String?, page: Int, size: Int): PageResponse<OpportunityResponse> {
        val pageable = PageRequest.of(page, size)
        val currentUserId = try { currentUserProvider.getCurrentUserId() } catch (_: Exception) { null }

        val pageResult = if (!type.isNullOrBlank()) {
            opportunityRepository.findAllByOpportunityTypeAndDeletedAtIsNullOrderByCreatedAtDesc(type, pageable)
        } else {
            opportunityRepository.findAllByDeletedAtIsNullOrderByCreatedAtDesc(pageable)
        }

        return PageResponse.from(pageResult) { opp ->
            val isApplied = currentUserId?.let { opportunityApplicationRepository.existsByOpportunityIdAndProfileId(opp.id, it) } ?: false
            opportunityMapper.toResponse(opp, isApplied)
        }
    }

    @Transactional(readOnly = true)
    fun getOpportunityById(id: String): OpportunityResponse {
        val opp = opportunityRepository.findByIdAndDeletedAtIsNull(id)
            .orElseThrow { ResourceNotFoundException("Opportunity with id $id not found") }
        val currentUserId = try { currentUserProvider.getCurrentUserId() } catch (_: Exception) { null }
        val isApplied = currentUserId?.let { opportunityApplicationRepository.existsByOpportunityIdAndProfileId(opp.id, it) } ?: false
        return opportunityMapper.toResponse(opp, isApplied)
    }

    fun createOpportunity(request: CreateOpportunityRequest): OpportunityResponse {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val poster = profileRepository.findById(currentUserId).orElse(null)

        val slug = request.title.lowercase().replace("\\s+".toRegex(), "-") + "-" + System.currentTimeMillis().toString().takeLast(4)

        val entity = OpportunityEntity(
            postedBy = poster,
            companyName = request.companyName,
            title = request.title,
            slug = slug,
            opportunityType = request.opportunityType ?: "INTERNSHIP",
            description = request.description,
            requirements = request.requirements,
            location = request.location,
            isRemote = request.isRemote,
            stipendOrSalary = request.stipendOrSalary,
            deadline = request.deadline,
            applyUrl = request.applyUrl
        )

        val saved = opportunityRepository.save(entity)

        domainEventPublisher.publishOpportunityCreated(
            OpportunityCreatedEvent(
                opportunityId = saved.id,
                title = saved.title,
                companyName = saved.companyName,
                opportunityType = saved.opportunityType
            )
        )

        return opportunityMapper.toResponse(saved, false)
    }

    fun apply(id: String, request: ApplyOpportunityRequest): Boolean {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val opp = opportunityRepository.findByIdAndDeletedAtIsNull(id)
            .orElseThrow { ResourceNotFoundException("Opportunity with id $id not found") }

        val profile = profileRepository.findById(currentUserId)
            .orElseThrow { ResourceNotFoundException("User profile not found") }

        val resume = request.resumeId?.let { resumeRepository.findById(it).orElse(null) }

        // Use distributed lock for atomic submission idempotency
        redisDistributedLock.withLock("opportunity:apply:$id:$currentUserId") {
            if (!opportunityApplicationRepository.existsByOpportunityIdAndProfileId(id, currentUserId)) {
                val application = opportunityApplicationRepository.save(
                    OpportunityApplicationEntity(
                        opportunity = opp,
                        profile = profile,
                        resume = resume,
                        coverNote = request.coverNote
                    )
                )
                opp.applicationsCount += 1
                opportunityRepository.save(opp)

                domainEventPublisher.publishApplicationSubmitted(
                    ApplicationSubmittedEvent(
                        applicationId = application.id,
                        opportunityId = opp.id,
                        opportunityTitle = opp.title,
                        posterId = opp.postedBy?.id,
                        applicantId = profile.id,
                        applicantName = profile.fullName
                    )
                )
            }
        }

        return true
    }
}
