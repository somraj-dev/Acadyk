package com.acadyk.modules.events.repository

import com.acadyk.modules.events.entity.EventEntity
import com.acadyk.modules.events.entity.EventRegistrationEntity
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.Optional
import java.util.UUID

@Repository
interface EventRepository : JpaRepository<EventEntity, UUID> {
    fun findAllByDeletedAtIsNullOrderByStartTimeDesc(pageable: Pageable): Page<EventEntity>
    fun findAllByEventTypeAndDeletedAtIsNullOrderByStartTimeDesc(eventType: String, pageable: Pageable): Page<EventEntity>
    fun findByIdAndDeletedAtIsNull(id: UUID): Optional<EventEntity>
}

@Repository
interface EventRegistrationRepository : JpaRepository<EventRegistrationEntity, UUID> {
    fun existsByEventIdAndProfileId(eventId: UUID, profileId: UUID): Boolean
    fun findAllByProfileId(profileId: UUID): List<EventRegistrationEntity>
}
