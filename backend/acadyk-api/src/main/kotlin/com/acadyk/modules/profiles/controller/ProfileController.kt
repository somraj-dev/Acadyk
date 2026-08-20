package com.acadyk.modules.profiles.controller

import com.acadyk.common.ApiResponse
import com.acadyk.common.PageResponse
import com.acadyk.modules.profiles.dto.*
import com.acadyk.modules.profiles.service.ProfileService
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/v1")
class ProfileController(private val profileService: ProfileService) {

    @GetMapping("/profiles/{id}")
    fun getProfile(@PathVariable id: String): ResponseEntity<ApiResponse<ProfileResponse>> {
        val profile = profileService.getProfileById(id)
        return ResponseEntity.ok(ApiResponse.success(profile))
    }

    @PutMapping("/me/profile")
    fun updateMyProfile(@Valid @RequestBody request: UpdateProfileRequest): ResponseEntity<ApiResponse<ProfileResponse>> {
        val updated = profileService.updateMyProfile(request)
        return ResponseEntity.ok(ApiResponse.success(updated, "Profile updated successfully"))
    }

    @PutMapping("/profiles/{id}")
    fun updateProfile(
        @PathVariable id: String,
        @RequestBody request: UpdateProfileRequest
    ): ResponseEntity<ApiResponse<ProfileResponse>> {
        val updated = profileService.updateMyProfile(request)
        return ResponseEntity.ok(ApiResponse.success(updated))
    }

    @GetMapping("/profiles/{id}/education")
    fun getEducation(@PathVariable id: String): ResponseEntity<ApiResponse<List<EducationDto>>> {
        return ResponseEntity.ok(ApiResponse.success(profileService.getEducation(id)))
    }

    @PostMapping("/me/education")
    fun addEducation(@Valid @RequestBody dto: EducationDto): ResponseEntity<ApiResponse<EducationDto>> {
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(ApiResponse.success(profileService.addEducation(dto), "Education added"))
    }

    @GetMapping("/profiles/{id}/experiences")
    fun getExperiences(@PathVariable id: String): ResponseEntity<ApiResponse<List<ExperienceDto>>> {
        return ResponseEntity.ok(ApiResponse.success(profileService.getExperiences(id)))
    }

    @PostMapping("/me/experiences")
    fun addExperience(@Valid @RequestBody dto: ExperienceDto): ResponseEntity<ApiResponse<ExperienceDto>> {
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(ApiResponse.success(profileService.addExperience(dto), "Experience added"))
    }

    @GetMapping("/profiles/{id}/certificates")
    fun getCertificates(@PathVariable id: String): ResponseEntity<ApiResponse<List<CertificateDto>>> {
        return ResponseEntity.ok(ApiResponse.success(profileService.getCertificates(id)))
    }

    @PostMapping("/me/certificates")
    fun addCertificate(@Valid @RequestBody dto: CertificateDto): ResponseEntity<ApiResponse<CertificateDto>> {
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(ApiResponse.success(profileService.addCertificate(dto), "Certificate added"))
    }

    @GetMapping("/profiles/{id}/resumes")
    fun getResumes(@PathVariable id: String): ResponseEntity<ApiResponse<List<ResumeDto>>> {
        return ResponseEntity.ok(ApiResponse.success(profileService.getResumes(id)))
    }

    @PostMapping("/me/resumes")
    fun addResume(@Valid @RequestBody dto: ResumeDto): ResponseEntity<ApiResponse<ResumeDto>> {
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(ApiResponse.success(profileService.addResume(dto), "Resume saved"))
    }

    @GetMapping("/search/profiles")
    fun searchProfiles(
        @RequestParam(name = "q", defaultValue = "") query: String,
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "20") size: Int
    ): ResponseEntity<ApiResponse<PageResponse<ProfileResponse>>> {
        val result = profileService.searchProfiles(query, page, size)
        return ResponseEntity.ok(ApiResponse.success(result))
    }
}
