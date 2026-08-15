package com.acadyk.modules.auth.service

import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.Test

class EnrollmentNumberServiceTest {

    private val service = EnrollmentNumberService()

    @Test
    fun `should parse MITS AI ML student email into exact expected enrollment number`() {
        val email = "25am10so80@mitsgwl.ac.in"
        assertTrue(service.isCollegeEmail(email), "Email domain should be verified as MITS")

        val result = service.parseCollegeEmail(email)
        assertTrue(result.isValid, "Parsed result should be marked valid")
        assertEquals("BTAM25O1080", result.enrollmentNumber)
        assertEquals("B.Tech", result.degree)
        assertEquals("Artificial Intelligence and Machine Learning", result.branch)
        assertEquals(2025, result.joiningYear)
    }

    @Test
    fun `should parse standard CSE student email`() {
        val email = "22cs1001@mitsgwl.ac.in"
        assertTrue(service.isCollegeEmail(email))

        val result = service.parseCollegeEmail(email)
        assertTrue(result.isValid)
        assertEquals("BTCS221001", result.enrollmentNumber)
        assertEquals("Computer Science and Engineering", result.branch)
        assertEquals(2022, result.joiningYear)
    }

    @Test
    fun `should parse IT student email with SO roll token`() {
        val email = "24it10so45@mitsgwl.ac.in"
        assertTrue(service.isCollegeEmail(email))

        val result = service.parseCollegeEmail(email)
        assertTrue(result.isValid)
        assertEquals("BTIT24O1045", result.enrollmentNumber)
        assertEquals("Information Technology", result.branch)
        assertEquals(2024, result.joiningYear)
    }

    @Test
    fun `should reject personal and non-college email domains`() {
        assertFalse(service.isCollegeEmail("somraj@gmail.com"))
        assertFalse(service.isCollegeEmail("student@yahoo.com"))
        assertFalse(service.isCollegeEmail("user@otheruniv.edu.in"))
    }

    @Test
    fun `should handle malformed email without generating incorrect enrollment`() {
        val malformedEmail = "invalid.faculty@mitsgwl.ac.in"
        assertTrue(service.isCollegeEmail(malformedEmail))

        val result = service.parseCollegeEmail(malformedEmail)
        assertFalse(result.isValid, "Malformed email should not be marked valid")
        assertTrue(result.enrollmentNumber.startsWith("PENDING_"))
        assertNotNull(result.failureReason)
    }
}
