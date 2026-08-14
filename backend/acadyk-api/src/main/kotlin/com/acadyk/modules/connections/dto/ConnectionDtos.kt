package com.acadyk.modules.connections.dto

import com.acadyk.modules.profiles.dto.ProfileResponse
import java.time.Instant

data class SendConnectionRequest(
    val recipientId: String,
    val message: String? = null
)

data class ConnectionRequestResponse(
    val id: String,
    val sender: ProfileResponse,
    val recipient: ProfileResponse,
    val status: String,
    val message: String?,
    val createdAt: Instant
)

data class FollowStatusResponse(
    val targetUserId: String,
    val isFollowing: Boolean
)
