package com.acadyk.modules.connections.mapper

import com.acadyk.modules.connections.dto.ConnectionRequestResponse
import com.acadyk.modules.connections.entity.ConnectionRequestEntity
import com.acadyk.modules.profiles.mapper.ProfileMapper
import org.springframework.stereotype.Component

@Component
class ConnectionMapper(private val profileMapper: ProfileMapper) {

    fun toResponse(entity: ConnectionRequestEntity): ConnectionRequestResponse {
        return ConnectionRequestResponse(
            id = entity.id,
            sender = profileMapper.toResponse(entity.sender),
            recipient = profileMapper.toResponse(entity.recipient),
            status = entity.status,
            message = entity.message,
            createdAt = entity.createdAt
        )
    }
}
