package com.acadyk.modules.files.repository

import com.acadyk.modules.files.entity.FileEntity
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.Optional

@Repository
interface FileRepository : JpaRepository<FileEntity, String> {
    fun findByFileKey(fileKey: String): Optional<FileEntity>
}
