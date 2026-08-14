package com.acadyk.modules.clubs.repository

import com.acadyk.modules.clubs.entity.ClubEntity
import com.acadyk.modules.clubs.entity.ClubMemberEntity
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.Optional

@Repository
interface ClubRepository : JpaRepository<ClubEntity, String> {
    fun findAllByDeletedAtIsNullOrderByMembersCountDesc(pageable: Pageable): Page<ClubEntity>
    fun findAllByCollegeNameAndDeletedAtIsNull(collegeName: String, pageable: Pageable): Page<ClubEntity>
    fun findByIdAndDeletedAtIsNull(id: String): Optional<ClubEntity>
}

@Repository
interface ClubMemberRepository : JpaRepository<ClubMemberEntity, String> {
    fun existsByClubIdAndProfileId(clubId: String, profileId: String): Boolean
    fun findByClubIdAndProfileId(clubId: String, profileId: String): Optional<ClubMemberEntity>
}
