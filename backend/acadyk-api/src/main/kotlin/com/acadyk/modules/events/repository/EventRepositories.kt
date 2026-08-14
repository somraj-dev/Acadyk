package com.acadyk.modules.events.repository

import com.acadyk.modules.events.entity.EventEntity
import com.acadyk.modules.events.entity.EventRegistrationEntity
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.Optional

@Repository
interface EventRepository : JpaRepository<EventEntity, String> {
    fun findAllByDeletedAtIsNullOrderByStartTimeDesc(pageable: Pageable): Page<EventEntity>
    fun findAllByEventTypeAndDeletedAtIsNullOrderByStartTimeDesc(eventType: String, pageable: Pageable): Page<EventEntity>
    fun findByIdAndDeletedAtIsNull(id: String): Optional<EventEntity>
}

@Repository
interface EventRegistrationRepository : JpaRepository<EventRegistrationEntity, String> {
    fun existsByEventIdAndProfileId(eventId: String, profileId: String): Boolean
    fun findAllByProfileId(profileId: String): List<EventRegistrationEntity>
}
