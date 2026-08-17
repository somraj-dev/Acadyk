package com.acadyk.modules.connections.repository

import com.acadyk.modules.connections.entity.ConnectionEntity
import com.acadyk.modules.connections.entity.ConnectionRequestEntity
import com.acadyk.modules.connections.entity.FollowEntity
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.Optional
import java.util.UUID

@Repository
interface ConnectionRepository : JpaRepository<ConnectionEntity, UUID> {
    fun findAllByUserAIdOrUserBId(userAId: UUID, userBId: UUID): List<ConnectionEntity>
    fun existsByUserAIdAndUserBId(userAId: UUID, userBId: UUID): Boolean
}

@Repository
interface ConnectionRequestRepository : JpaRepository<ConnectionRequestEntity, UUID> {
    fun findAllByRecipientIdAndStatus(recipientId: UUID, status: String): List<ConnectionRequestEntity>
    fun findBySenderIdAndRecipientId(senderId: UUID, recipientId: UUID): Optional<ConnectionRequestEntity>
}

@Repository
interface FollowRepository : JpaRepository<FollowEntity, UUID> {
    fun findAllByFollowingId(followingId: UUID): List<FollowEntity>
    fun findAllByFollowerId(followerId: UUID): List<FollowEntity>
    fun findByFollowerIdAndFollowingId(followerId: UUID, followingId: UUID): Optional<FollowEntity>
    fun existsByFollowerIdAndFollowingId(followerId: UUID, followingId: UUID): Boolean
}
