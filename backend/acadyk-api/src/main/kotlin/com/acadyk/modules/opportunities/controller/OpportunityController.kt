package com.acadyk.modules.opportunities.controller

import com.acadyk.common.ApiResponse
import com.acadyk.common.PageResponse
import com.acadyk.modules.opportunities.dto.ApplyOpportunityRequest
import com.acadyk.modules.opportunities.dto.CreateOpportunityRequest
import com.acadyk.modules.opportunities.dto.OpportunityResponse
import com.acadyk.modules.opportunities.service.OpportunityService
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/v1/opportunities")
@CrossOrigin(origins = ["*"])
class OpportunityController(private val opportunityService: OpportunityService) {

    @GetMapping
    fun getOpportunities(
        @RequestParam(required = false) type: String?,
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "20") size: Int
    ): ResponseEntity<ApiResponse<PageResponse<OpportunityResponse>>> {
        val result = opportunityService.getOpportunities(type, page, size)
        return ResponseEntity.ok(ApiResponse.success(result))
    }

    @GetMapping("/{id}")
    fun getOpportunityById(@PathVariable id: String): ResponseEntity<ApiResponse<OpportunityResponse>> {
        val result = opportunityService.getOpportunityById(id)
        return ResponseEntity.ok(ApiResponse.success(result))
    }

    @PostMapping
    fun createOpportunity(@Valid @RequestBody request: CreateOpportunityRequest): ResponseEntity<ApiResponse<OpportunityResponse>> {
        val result = opportunityService.createOpportunity(request)
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(ApiResponse.success(result, "Opportunity posted successfully"))
    }

    @PostMapping("/{id}/apply")
    fun apply(
        @PathVariable id: String,
        @RequestBody request: ApplyOpportunityRequest
    ): ResponseEntity<ApiResponse<Map<String, Boolean>>> {
        val success = opportunityService.apply(id, request)
        return ResponseEntity.ok(ApiResponse.success(mapOf("applied" to success)))
    }
}
