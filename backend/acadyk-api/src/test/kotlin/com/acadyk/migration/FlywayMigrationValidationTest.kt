package com.acadyk.migration

import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.Test
import org.springframework.core.io.support.PathMatchingResourcePatternResolver

class FlywayMigrationValidationTest {

    @Test
    fun `verify all Flyway SQL migration scripts exist and contain valid DDL`() {
        val resolver = PathMatchingResourcePatternResolver()
        val resources = resolver.getResources("classpath:db/migration/V*.sql")

        assertTrue(resources.isNotEmpty(), "Flyway migrations directory must contain SQL scripts")
        assertTrue(resources.size >= 13, "Expected at least 13 Flyway migration files")

        val filenames = resources.mapNotNull { it.filename }.sorted()
        for (i in 1..resources.size) {
            val expectedPrefix = "V${i}__"
            val match = filenames.find { it.startsWith(expectedPrefix) }
            assertNotNull(match, "Migration script starting with $expectedPrefix must exist")
        }

        // Verify each script is non-empty
        for (resource in resources) {
            val content = resource.inputStream.bufferedReader().use { it.readText() }
            assertTrue(content.trim().isNotEmpty(), "${resource.filename} must not be empty")
            assertTrue(
                content.contains("CREATE") || content.contains("ALTER") || content.contains("INSERT"),
                "${resource.filename} must contain DDL/DML statements"
            )
        }
    }
}
