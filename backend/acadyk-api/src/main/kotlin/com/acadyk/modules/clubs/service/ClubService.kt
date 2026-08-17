package com.acadyk.modules.clubs.service

import com.acadyk.common.PageResponse
import com.acadyk.common.ResourceNotFoundException
import com.acadyk.common.toUUID
import com.acadyk.modules.clubs.dto.ClubResponse
import com.acadyk.modules.clubs.dto.CreateClubRequest
import com.acadyk.modules.clubs.entity.ClubEntity
import com.acadyk.modules.clubs.entity.ClubMemberEntity
import com.acadyk.modules.clubs.mapper.ClubMapper
import com.acadyk.modules.clubs.repository.ClubMemberRepository
import com.acadyk.modules.clubs.repository.ClubRepository
import com.acadyk.modules.profiles.repository.ProfileRepository
import com.acadyk.security.CurrentUserProvider
import org.springframework.data.domain.PageRequest
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

@Service
@Transactional
class ClubService(
    private val clubRepository: ClubRepository,
    private val clubMemberRepository: ClubMemberRepository,
    private val profileRepository: ProfileRepository,
    private val clubMapper: ClubMapper,
    private val currentUserProvider: CurrentUserProvider
) {

    @Transactional(readOnly = true)
    fun getClubs(college: String?, page: Int, size: Int): PageResponse<ClubResponse> {
        val pageable = PageRequest.of(page, size)
        val currentUserId = try { currentUserProvider.getCurrentUserId() } catch (_: Exception) { null }

        val pageResult = if (!college.isNullOrBlank()) {
            clubRepository.findAllByCollegeNameAndDeletedAtIsNull(college, pageable)
        } else {
            clubRepository.findAllByDeletedAtIsNullOrderByMembersCountDesc(pageable)
        }

        return PageResponse.from(pageResult) { club ->
            val isMember = currentUserId?.let { clubMemberRepository.existsByClubIdAndProfileId(club.id, it) } ?: false
            clubMapper.toResponse(club, isMember)
        }
    }

    @Transactional(readOnly = true)
    fun getClubById(id: UUID): ClubResponse {
        val club = clubRepository.findByIdAndDeletedAtIsNull(id)
            .orElseThrow { ResourceNotFoundException("Club with id $id not found") }
        val currentUserId = try { currentUserProvider.getCurrentUserId() } catch (_: Exception) { null }
        val isMember = currentUserId?.let { clubMemberRepository.existsByClubIdAndProfileId(club.id, it) } ?: false
        return clubMapper.toResponse(club, isMember)
    }

    @Transactional(readOnly = true)
    fun getClubById(id: String): ClubResponse = getClubById(id.toUUID())

    fun createClub(request: CreateClubRequest): ClubResponse {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val creator = profileRepository.findById(currentUserId).orElse(null)

        val slug = request.name.lowercase().replace("\\s+".toRegex(), "-") + "-" + System.currentTimeMillis().toString().takeLast(4)

        val entity = ClubEntity(
            creator = creator,
            collegeName = request.collegeName,
            name = request.name,
            slug = slug,
            description = request.description,
            category = request.category ?: "Technical",
            logoUrl = request.logoUrl,
            bannerUrl = request.bannerUrl
        )

        val saved = clubRepository.save(entity)
        if (creator != null) {
            clubMemberRepository.save(ClubMemberEntity(club = saved, profile = creator, role = "LEAD"))
        }

        return clubMapper.toResponse(saved, true)
    }

    fun toggleJoin(clubId: UUID): Boolean {
        val currentUserId = currentUserProvider.getCurrentUserId()
        val club = clubRepository.findByIdAndDeletedAtIsNull(clubId)
            .orElseThrow { ResourceNotFoundException("Club not found") }
        val profile = profileRepository.findById(currentUserId)
            .orElseThrow { ResourceNotFoundException("Profile not found") }

        val existing = clubMemberRepository.findByClubIdAndProfileId(clubId, currentUserId)
        return if (existing.isPresent) {
            clubMemberRepository.delete(existing.get())
            club.membersCount = maxOf(0, club.membersCount - 1)
            clubRepository.save(club)
            false
        } else {
            clubMemberRepository.save(ClubMemberEntity(club = club, profile = profile))
            club.membersCount += 1
            clubRepository.save(club)
            true
        }
    }

    fun toggleJoin(clubId: String): Boolean = toggleJoin(clubId.toUUID())
}
