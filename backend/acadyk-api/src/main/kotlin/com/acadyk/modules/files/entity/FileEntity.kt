package com.acadyk.modules.files.entity

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Id
import jakarta.persistence.Table
import java.time.Instant
import java.util.UUID

@Entity
@Table(name = "files")
data class FileEntity(
    @Id
    val id: UUID = UUID.randomUUID(),

    var uploaderId: UUID? = null,

    @Column(nullable = false)
    var bucketName: String = "acadyk-media-production",

    @Column(nullable = false, unique = true)
    var fileKey: String,

    @Column(nullable = false)
    var fileName: String,

    @Column(nullable = false)
    var contentType: String,

    @Column(nullable = false)
    var fileSizeBytes: Long,

    var isPublic: Boolean = true,

    @Column(nullable = false)
    val createdAt: Instant = Instant.now()
)
