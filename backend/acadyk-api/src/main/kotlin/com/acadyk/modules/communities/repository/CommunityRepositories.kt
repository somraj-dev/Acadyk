package com.acadyk.modules.communities.repository

import com.acadyk.modules.communities.entity.CommunityEntity
import com.acadyk.modules.communities.entity.CommunityMemberEntity
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.Optional
import java.util.UUID

@Repository
interface CommunityRepository : JpaRepository<CommunityEntity, UUID> {
    fun findAllByDeletedAtIsNullOrderByMembersCountDesc(pageable: Pageable): Page<CommunityEntity>
    fun findAllByCategoryAndDeletedAtIsNull(category: String, pageable: Pageable): Page<CommunityEntity>
    fun findByIdAndDeletedAtIsNull(id: UUID): Optional<CommunityEntity>
    fun findBySlug(slug: String): Optional<CommunityEntity>
}

@Repository
interface CommunityMemberRepository : JpaRepository<CommunityMemberEntity, UUID> {
    fun existsByCommunityIdAndProfileId(communityId: UUID, profileId: UUID): Boolean
    fun findByCommunityIdAndProfileId(communityId: UUID, profileId: UUID): Optional<CommunityMemberEntity>
    fun findAllByProfileId(profileId: UUID): List<CommunityMemberEntity>
}
