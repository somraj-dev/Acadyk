package com.acadyk.modules.communities.repository

import com.acadyk.modules.communities.entity.CommunityEntity
import com.acadyk.modules.communities.entity.CommunityMemberEntity
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.Optional

@Repository
interface CommunityRepository : JpaRepository<CommunityEntity, String> {
    fun findAllByDeletedAtIsNullOrderByMembersCountDesc(pageable: Pageable): Page<CommunityEntity>
    fun findAllByCategoryAndDeletedAtIsNull(category: String, pageable: Pageable): Page<CommunityEntity>
    fun findByIdAndDeletedAtIsNull(id: String): Optional<CommunityEntity>
    fun findBySlug(slug: String): Optional<CommunityEntity>
}

@Repository
interface CommunityMemberRepository : JpaRepository<CommunityMemberEntity, String> {
    fun existsByCommunityIdAndProfileId(communityId: String, profileId: String): Boolean
    fun findByCommunityIdAndProfileId(communityId: String, profileId: String): Optional<CommunityMemberEntity>
    fun findAllByProfileId(profileId: String): List<CommunityMemberEntity>
}
