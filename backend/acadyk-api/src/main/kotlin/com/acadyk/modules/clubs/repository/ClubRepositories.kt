package com.acadyk.modules.clubs.repository

import com.acadyk.modules.clubs.entity.ClubEntity
import com.acadyk.modules.clubs.entity.ClubMemberEntity
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.Optional
import java.util.UUID

@Repository
interface ClubRepository : JpaRepository<ClubEntity, UUID> {
    fun findAllByDeletedAtIsNullOrderByMembersCountDesc(pageable: Pageable): Page<ClubEntity>
    fun findAllByCollegeNameAndDeletedAtIsNull(collegeName: String, pageable: Pageable): Page<ClubEntity>
    fun findByIdAndDeletedAtIsNull(id: UUID): Optional<ClubEntity>
}

@Repository
interface ClubMemberRepository : JpaRepository<ClubMemberEntity, UUID> {
    fun existsByClubIdAndProfileId(clubId: UUID, profileId: UUID): Boolean
    fun findByClubIdAndProfileId(clubId: UUID, profileId: UUID): Optional<ClubMemberEntity>
}
