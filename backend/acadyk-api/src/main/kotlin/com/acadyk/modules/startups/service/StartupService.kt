package com.acadyk.modules.startups.service

import com.acadyk.common.PageResponse
import com.acadyk.common.ResourceNotFoundException
import com.acadyk.modules.profiles.repository.ProfileRepository
import com.acadyk.modules.startups.dto.CreateStartupRequest
import com.acadyk.modules.startups.dto.StartupResponse
import com.acadyk.modules.startups.entity.StartupEntity
import com.acadyk.modules.startups.entity.StartupMediaEntity
import com.acadyk.modules.startups.entity.StartupMemberEntity
import com.acadyk.modules.startups.mapper.StartupMapper
import com.acadyk.modules.startups.repository.StartupMediaRepository
import com.acadyk.modules.startups.repository.StartupMemberRepository
import com.acadyk.modules.startups.repository.StartupRepository
import com.acadyk.security.CurrentUserProvider
import org.springframework.data.domain.PageRequest
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@Transactional
class StartupService(
    private val startupRepository: StartupRepository,
    private val startupMemberRepository: StartupMemberRepository,
    private val startupMediaRepository: StartupMediaRepository,
    private val profileRepository: ProfileRepository,
    private val startupMapper: StartupMapper,
    private val currentUserProvider: CurrentUserProvider
) {

    @Transactional(readOnly = true)
    fun getStartups(stage: String?, page: Int, size: Int): PageResponse<StartupResponse> {
        val pageable = PageRequest.of(page, size)
        val pageResult = if (!stage.isNullOrBlank()) {
            startupRepository.findAllByStageAndDeletedAtIsNull(stage, pageable)
        } else {
            startupRepository.findAllByDeletedAtIsNullOrderByCreatedAtDesc(pageable)
        }

        return PageResponse.from(pageResult) { startup ->
            val media = startupMediaRepository.findAllByStartupIdOrderByPositionAsc(startup.id)
            startupMapper.toResponse(startup, media)
        }
    }

    @Transactional(readOnly = true)
    fun getStartupById(id: String): StartupResponse {
        val startup = startupRepository.findByIdAndDeletedAtIsNull(id)
            .orElseThrow { ResourceNotFoundException("Startup with id $id not found") }
        val media = startupMediaRepository.findAllByStartupIdOrderByPositionAsc(startup.id)
        return startupMapper.toResponse(startup, media)
    }

    fun createStartup(request: CreateStartupRequest): StartupResponse {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val founder = profileRepository.findById(currentUserId)
            .orElseThrow { ResourceNotFoundException("User profile not found") }

        val slug = request.name.lowercase().replace("\\s+".toRegex(), "-") + "-" + System.currentTimeMillis().toString().takeLast(4)

        val entity = StartupEntity(
            founder = founder,
            name = request.name,
            slug = slug,
            pitch = request.pitch,
            description = request.description,
            stage = request.stage ?: "Idea",
            industry = request.industry,
            websiteUrl = request.websiteUrl,
            logoUrl = request.logoUrl,
            bannerUrl = request.bannerUrl
        )

        val saved = startupRepository.save(entity)
        startupMemberRepository.save(StartupMemberEntity(startup = saved, profile = founder, roleTitle = "Founder & CEO", isAdmin = true))

        val savedMedia = mutableListOf<StartupMediaEntity>()
        request.mediaUrls?.forEachIndexed { idx, url ->
            savedMedia.add(startupMediaRepository.save(StartupMediaEntity(startupId = saved.id, mediaUrl = url, position = idx)))
        }

        return startupMapper.toResponse(saved, savedMedia)
    }
}
