package com.acadyk.modules.leaderboard.entity

import com.acadyk.modules.profiles.entity.ProfileEntity
import jakarta.persistence.*
import java.time.Instant
import java.time.LocalDate
import java.util.UUID

@Entity
@Table(name = "leaderboard_entries")
data class LeaderboardEntryEntity(
    @Id
    val id: String = UUID.randomUUID().toString(),

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "profile_id", nullable = false)
    val profile: ProfileEntity,

    var category: String = "Global Impact",
    var score: Int = 0,
    var rank: Int = 1,
    var period: String = "ALL_TIME",
    var snapshotDate: LocalDate = LocalDate.now(),

    @Column(nullable = false)
    val createdAt: Instant = Instant.now()
)
