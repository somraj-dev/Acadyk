package com.acadyk.modules.communities.service

import com.acadyk.common.PageResponse
import com.acadyk.common.ResourceNotFoundException
import com.acadyk.common.toUUID
import com.acadyk.modules.communities.dto.CommunityResponse
import com.acadyk.modules.communities.dto.CreateCommunityRequest
import com.acadyk.modules.communities.entity.CommunityEntity
import com.acadyk.modules.communities.entity.CommunityMemberEntity
import com.acadyk.modules.communities.mapper.CommunityMapper
import com.acadyk.modules.communities.repository.CommunityMemberRepository
import com.acadyk.modules.communities.repository.CommunityRepository
import com.acadyk.modules.profiles.repository.ProfileRepository
import com.acadyk.security.CurrentUserProvider
import org.springframework.data.domain.PageRequest
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

@Service
@Transactional
class CommunityService(
    private val communityRepository: CommunityRepository,
    private val communityMemberRepository: CommunityMemberRepository,
    private val profileRepository: ProfileRepository,
    private val communityMapper: CommunityMapper,
    private val currentUserProvider: CurrentUserProvider
) {

    @Transactional(readOnly = true)
    fun getCommunities(category: String?, page: Int, size: Int): PageResponse<CommunityResponse> {
        val pageable = PageRequest.of(page, size)
        val currentUserId = try { currentUserProvider.getCurrentUserId() } catch (_: Exception) { null }

        val pageResult = if (!category.isNullOrBlank()) {
            communityRepository.findAllByCategoryAndDeletedAtIsNull(category, pageable)
        } else {
            communityRepository.findAllByDeletedAtIsNullOrderByMembersCountDesc(pageable)
        }

        return PageResponse.from(pageResult) { community ->
            val isMember = currentUserId?.let { communityMemberRepository.existsByCommunityIdAndProfileId(community.id, it) } ?: false
            communityMapper.toResponse(community, isMember)
        }
    }

    @Transactional(readOnly = true)
    fun getCommunityById(id: UUID): CommunityResponse {
        val community = communityRepository.findByIdAndDeletedAtIsNull(id)
            .orElseThrow { ResourceNotFoundException("Community with id $id not found") }
        val currentUserId = try { currentUserProvider.getCurrentUserId() } catch (_: Exception) { null }
        val isMember = currentUserId?.let { communityMemberRepository.existsByCommunityIdAndProfileId(community.id, it) } ?: false
        return communityMapper.toResponse(community, isMember)
    }

    @Transactional(readOnly = true)
    fun getCommunityById(id: String): CommunityResponse = getCommunityById(id.toUUID())

    fun createCommunity(request: CreateCommunityRequest): CommunityResponse {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val creator = profileRepository.findById(currentUserId).orElse(null)

        val slug = request.name.lowercase().replace("\\s+".toRegex(), "-") + "-" + System.currentTimeMillis().toString().takeLast(4)

        val community = CommunityEntity(
            creator = creator,
            name = request.name,
            slug = slug,
            description = request.description,
            category = request.category ?: "academic",
            avatarUrl = request.avatarUrl,
            bannerUrl = request.bannerUrl,
            isPrivate = request.isPrivate,
            membersCount = 1
        )

        val saved = communityRepository.save(community)

        if (creator != null) {
            communityMemberRepository.save(CommunityMemberEntity(community = saved, profile = creator, role = "ADMIN"))
        }

        return communityMapper.toResponse(saved, true)
    }

    fun toggleMembership(communityId: UUID): Boolean {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val community = communityRepository.findByIdAndDeletedAtIsNull(communityId)
            .orElseThrow { ResourceNotFoundException("Community not found") }
        val profile = profileRepository.findById(currentUserId)
            .orElseThrow { ResourceNotFoundException("Profile not found") }

        val existing = communityMemberRepository.findByCommunityIdAndProfileId(communityId, currentUserId)
        return if (existing.isPresent) {
            communityMemberRepository.delete(existing.get())
            community.membersCount = maxOf(0, community.membersCount - 1)
            communityRepository.save(community)
            false
        } else {
            communityMemberRepository.save(CommunityMemberEntity(community = community, profile = profile))
            community.membersCount += 1
            communityRepository.save(community)
            true
        }
    }

    fun toggleMembership(communityId: String): Boolean = toggleMembership(communityId.toUUID())
}
