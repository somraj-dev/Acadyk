package com.acadyk.modules.connections.repository

import com.acadyk.modules.connections.entity.ConnectionEntity
import com.acadyk.modules.connections.entity.ConnectionRequestEntity
import com.acadyk.modules.connections.entity.FollowEntity
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.Optional

@Repository
interface ConnectionRepository : JpaRepository<ConnectionEntity, String> {
    fun findAllByUserAIdOrUserBId(userAId: String, userBId: String): List<ConnectionEntity>
    fun existsByUserAIdAndUserBId(userAId: String, userBId: String): Boolean
}

@Repository
interface ConnectionRequestRepository : JpaRepository<ConnectionRequestEntity, String> {
    fun findAllByRecipientIdAndStatus(recipientId: String, status: String): List<ConnectionRequestEntity>
    fun findBySenderIdAndRecipientId(senderId: String, recipientId: String): Optional<ConnectionRequestEntity>
}

@Repository
interface FollowRepository : JpaRepository<FollowEntity, String> {
    fun findAllByFollowingId(followingId: String): List<FollowEntity>
    fun findAllByFollowerId(followerId: String): List<FollowEntity>
    fun findByFollowerIdAndFollowingId(followerId: String, followingId: String): Optional<FollowEntity>
    fun existsByFollowerIdAndFollowingId(followerId: String, followingId: String): Boolean
}
