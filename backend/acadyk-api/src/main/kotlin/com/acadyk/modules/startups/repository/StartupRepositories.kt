package com.acadyk.modules.startups.repository

import com.acadyk.modules.startups.entity.StartupEntity
import com.acadyk.modules.startups.entity.StartupMediaEntity
import com.acadyk.modules.startups.entity.StartupMemberEntity
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.Optional

@Repository
interface StartupRepository : JpaRepository<StartupEntity, String> {
    fun findAllByDeletedAtIsNullOrderByCreatedAtDesc(pageable: Pageable): Page<StartupEntity>
    fun findAllByStageAndDeletedAtIsNull(stage: String, pageable: Pageable): Page<StartupEntity>
    fun findByIdAndDeletedAtIsNull(id: String): Optional<StartupEntity>
}

@Repository
interface StartupMemberRepository : JpaRepository<StartupMemberEntity, String> {
    fun findAllByStartupId(startupId: String): List<StartupMemberEntity>
    fun findAllByProfileId(profileId: String): List<StartupMemberEntity>
}

@Repository
interface StartupMediaRepository : JpaRepository<StartupMediaEntity, String> {
    fun findAllByStartupIdOrderByPositionAsc(startupId: String): List<StartupMediaEntity>
}
