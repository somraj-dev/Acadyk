package com.acadyk.modules.files.repository

import com.acadyk.modules.files.entity.FileEntity
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.Optional
import java.util.UUID

@Repository
interface FileRepository : JpaRepository<FileEntity, UUID> {
    fun findByFileKey(fileKey: String): Optional<FileEntity>
}
