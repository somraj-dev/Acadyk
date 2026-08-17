package com.acadyk.modules.startups.repository

import com.acadyk.modules.startups.entity.StartupEntity
import com.acadyk.modules.startups.entity.StartupMediaEntity
import com.acadyk.modules.startups.entity.StartupMemberEntity
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.Optional
import java.util.UUID

@Repository
interface StartupRepository : JpaRepository<StartupEntity, UUID> {
    fun findAllByDeletedAtIsNullOrderByCreatedAtDesc(pageable: Pageable): Page<StartupEntity>
    fun findAllByStageAndDeletedAtIsNull(stage: String, pageable: Pageable): Page<StartupEntity>
    fun findByIdAndDeletedAtIsNull(id: UUID): Optional<StartupEntity>
}

@Repository
interface StartupMemberRepository : JpaRepository<StartupMemberEntity, UUID> {
    fun findAllByStartupId(startupId: UUID): List<StartupMemberEntity>
    fun findAllByProfileId(profileId: UUID): List<StartupMemberEntity>
}

@Repository
interface StartupMediaRepository : JpaRepository<StartupMediaEntity, UUID> {
    fun findAllByStartupIdOrderByPositionAsc(startupId: UUID): List<StartupMediaEntity>
}
