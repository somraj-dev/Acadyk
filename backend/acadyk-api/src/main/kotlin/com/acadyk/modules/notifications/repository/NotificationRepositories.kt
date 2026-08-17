package com.acadyk.modules.notifications.repository

import com.acadyk.modules.notifications.entity.NotificationEntity
import com.acadyk.modules.notifications.entity.NotificationPreferenceEntity
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.Optional
import java.util.UUID

@Repository
interface NotificationRepository : JpaRepository<NotificationEntity, UUID> {
    fun findAllByRecipientIdOrderByCreatedAtDesc(recipientId: UUID, pageable: Pageable): Page<NotificationEntity>
    fun countByRecipientIdAndIsReadFalse(recipientId: UUID): Long
    fun findByIdAndRecipientId(id: UUID, recipientId: UUID): Optional<NotificationEntity>
}

@Repository
interface NotificationPreferenceRepository : JpaRepository<NotificationPreferenceEntity, UUID> {
    fun findByProfileId(profileId: UUID): Optional<NotificationPreferenceEntity>
}
