package com.acadyk.modules.auth.service

import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service

data class ParsedEnrollmentInfo(
    val enrollmentNumber: String,
    val degree: String,
    val branch: String,
    val branchCode: String,
    val joiningYear: Int,
    val isValid: Boolean,
    val failureReason: String? = null
)

@Service
class EnrollmentNumberService {
    private val logger = LoggerFactory.getLogger(javaClass)

    companion object {
        const val REQUIRED_DOMAIN = "mits.ac.in"
        const val DEFAULT_DEGREE = "B.Tech"
        const val DEFAULT_DEGREE_PREFIX = "BT"

        // Strict Regex for standard MITS email format ending in @mits.ac.in or @mitsgwl.ac.in
        private val MITS_EMAIL_FULL_REGEX = Regex("""^[a-zA-Z0-9._%+-]+@(mits|mitsgwl)\.ac\.in$""", RegexOption.IGNORE_CASE)

        // Comprehensive MITS Gwalior Branch code mappings
        private val BRANCH_MAP = mapOf(
            "am" to Pair("AM", "Artificial Intelligence and Machine Learning"),
            "ai" to Pair("AI", "Artificial Intelligence"),
            "ds" to Pair("DS", "Data Science"),
            "aids" to Pair("DS", "Artificial Intelligence and Data Science"),
            "iot" to Pair("IOT", "Internet of Things"),
            "aiiot" to Pair("IOT", "Artificial Intelligence and Internet of Things"),
            "cs" to Pair("CS", "Computer Science and Engineering"),
            "cse" to Pair("CS", "Computer Science and Engineering"),
            "it" to Pair("IT", "Information Technology"),
            "ec" to Pair("EC", "Electronics and Communication Engineering"),
            "ee" to Pair("EE", "Electrical Engineering"),
            "me" to Pair("ME", "Mechanical Engineering"),
            "ce" to Pair("CE", "Civil Engineering"),
            "ch" to Pair("CH", "Chemical Engineering"),
            "et" to Pair("ET", "Electronics and Telecommunication Engineering"),
            "au" to Pair("AU", "Automobile Engineering"),
            "ar" to Pair("AR", "Architecture"),
            "bt" to Pair("BT", "Biotechnology")
        )

        // Strict Regex for standard MITS email local part: e.g. 25am10so80 or 22cs1001
        private val MITS_EMAIL_REGEX = Regex("""^(\d{2})([a-zA-Z]{2,5})([a-zA-Z0-9]+)$""")
        
        // Strict Regex for generated institutional enrollment number
        private val ENROLLMENT_FORMAT_REGEX = Regex("""^BT[A-Z]{2,5}\d{2}[A-Z0-9]{3,7}$""")
    }

    /**
     * Checks if the email belongs strictly to the MITS institutional domain (@mits.ac.in).
     * Case-insensitive, rejects any other domain (gmail, outlook, mits.edu.in, fake domains, bypass attempts).
     */
    fun isCollegeEmail(email: String): Boolean {
        if (email.isBlank() || !email.contains("@")) return false
        val normalized = email.trim().lowercase()
        return MITS_EMAIL_FULL_REGEX.matches(normalized)
    }

    /**
     * Normalizes institutional email to lowercase trimmed format.
     */
    fun normalizeEmail(email: String): String = email.trim().lowercase()

    /**
     * Automatically converts a verified MITS college email into an institutional enrollment number
     * Example: "25am10so80@mitsgwl.ac.in" -> "BTAM25O1080"
     */
    fun parseCollegeEmail(email: String): ParsedEnrollmentInfo {
        val trimmedEmail = email.trim().lowercase()
        val localPart = trimmedEmail.substringBefore("@")

        val match = MITS_EMAIL_REGEX.find(localPart)
        if (match == null) {
            logger.warn("Email local part does not match standard pattern: {}", localPart)
            return ParsedEnrollmentInfo(
                enrollmentNumber = "PENDING_" + localPart.uppercase(),
                degree = DEFAULT_DEGREE,
                branch = "Engineering",
                branchCode = "GEN",
                joiningYear = 2025,
                isValid = false,
                failureReason = "Email local part '$localPart' does not conform to [Year][Branch][Serial] pattern"
            )
        }

        val (yearDigits, rawBranch, rawSerial) = match.destructured
        val joiningYear = 2000 + (yearDigits.toIntOrNull() ?: 25)

        // Resolve branch code and full name
        val branchInfo = BRANCH_MAP[rawBranch] ?: Pair(rawBranch.uppercase(), rawBranch.uppercase())
        val branchCode = branchInfo.first
        val branchName = branchInfo.second

        // Transform student serial token (e.g. 10so80 -> O1080)
        val transformedSerial = formatSerialComponent(rawSerial)

        // Construct full enrollment number: BT + Branch (AM) + Year (25) + Serial (O1080) -> BTAM25O1080
        val enrollmentNumber = "$DEFAULT_DEGREE_PREFIX$branchCode$yearDigits$transformedSerial"

        val isValid = ENROLLMENT_FORMAT_REGEX.matches(enrollmentNumber)
        if (!isValid) {
            logger.warn("Generated enrollment number failed format validation: {}", enrollmentNumber)
        }

        return ParsedEnrollmentInfo(
            enrollmentNumber = enrollmentNumber,
            degree = DEFAULT_DEGREE,
            branch = branchName,
            branchCode = branchCode,
            joiningYear = joiningYear,
            isValid = isValid,
            failureReason = if (isValid) null else "Generated enrollment '$enrollmentNumber' did not match format constraints"
        )
    }

    /**
     * Transforms raw student serial token into standardized MITS enrollment serial token
     * e.g., "10so80" -> "O1080", "101080" -> "101080", "01" -> "01"
     */
    private fun formatSerialComponent(rawSerial: String): String {
        val upper = rawSerial.uppercase()
        // If it contains "SO", extract digits and prepend 'O'
        return if (upper.contains("SO")) {
            val digits = upper.replace(Regex("[^0-9]"), "")
            "O$digits"
        } else if (upper.startsWith("SO")) {
            "O" + upper.removePrefix("SO")
        } else {
            upper
        }
    }
}
