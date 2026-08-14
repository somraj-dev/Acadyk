package com.acadyk.migration

import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.Test
import org.springframework.core.io.support.PathMatchingResourcePatternResolver

class FlywayMigrationValidationTest {

    @Test
    fun `verify all 13 Flyway SQL migration scripts exist and contain valid DDL`() {
        val resolver = PathMatchingResourcePatternResolver()
        val resources = resolver.getResources("classpath:db/migration/V*.sql")

        assertTrue(resources.isNotEmpty(), "Flyway migrations directory must contain SQL scripts")
        assertEquals(13, resources.size, "Expected exactly 13 Flyway migration files (V1 to V13)")

        val filenames = resources.mapNotNull { it.filename }.sorted()
        for (i in 1..13) {
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
