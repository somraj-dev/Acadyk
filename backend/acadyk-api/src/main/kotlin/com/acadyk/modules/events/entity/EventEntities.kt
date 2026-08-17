package com.acadyk.modules.events.entity

import com.acadyk.modules.profiles.entity.ProfileEntity
import jakarta.persistence.*
import org.hibernate.annotations.JdbcTypeCode
import org.hibernate.type.SqlTypes
import java.time.Instant
import java.util.UUID

@Entity
@Table(name = "events")
data class EventEntity(
    @Id
    val id: UUID = UUID.randomUUID(),

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "organizer_id")
    val organizer: ProfileEntity? = null,

    @Column(nullable = false)
    var title: String,

    @JdbcTypeCode(SqlTypes.OTHER)
    @Column(nullable = false, unique = true)
    var slug: String,

    @Column(columnDefinition = "TEXT")
    var description: String? = null,

    var eventType: String = "workshop",
    var location: String? = null,
    var isVirtual: Boolean = false,
    var meetingLink: String? = null,
    var startTime: Instant = Instant.now(),
    var endTime: Instant? = null,
    var bannerUrl: String? = null,
    var maxAttendees: Int? = null,
    var registrationsCount: Int = 0,

    @Column(nullable = false)
    val createdAt: Instant = Instant.now(),

    @Column(nullable = false)
    var updatedAt: Instant = Instant.now(),

    var deletedAt: Instant? = null
)

@Entity
@Table(name = "event_registrations")
data class EventRegistrationEntity(
    @Id
    val id: UUID = UUID.randomUUID(),

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "event_id", nullable = false)
    val event: EventEntity,

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "profile_id", nullable = false)
    val profile: ProfileEntity,

    var status: String = "REGISTERED",

    @Column(nullable = false)
    val registeredAt: Instant = Instant.now()
)
