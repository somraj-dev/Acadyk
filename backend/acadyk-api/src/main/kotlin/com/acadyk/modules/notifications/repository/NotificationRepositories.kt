package com.acadyk.modules.notifications.repository

import com.acadyk.modules.notifications.entity.NotificationEntity
import com.acadyk.modules.notifications.entity.NotificationPreferenceEntity
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.Optional

@Repository
interface NotificationRepository : JpaRepository<NotificationEntity, String> {
    fun findAllByRecipientIdOrderByCreatedAtDesc(recipientId: String, pageable: Pageable): Page<NotificationEntity>
    fun countByRecipientIdAndIsReadFalse(recipientId: String): Long
    fun findByIdAndRecipientId(id: String, recipientId: String): Optional<NotificationEntity>
}

@Repository
interface NotificationPreferenceRepository : JpaRepository<NotificationPreferenceEntity, String> {
    fun findByProfileId(profileId: String): Optional<NotificationPreferenceEntity>
}
