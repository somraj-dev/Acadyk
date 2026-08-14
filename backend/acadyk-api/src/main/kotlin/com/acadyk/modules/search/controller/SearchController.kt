package com.acadyk.modules.search.controller

import com.acadyk.common.ApiResponse
import com.acadyk.modules.search.dto.AutocompleteSuggestion
import com.acadyk.modules.search.dto.GlobalSearchResponse
import com.acadyk.modules.search.dto.SearchFilterParams
import com.acadyk.modules.search.service.SearchService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/v1/search")
@CrossOrigin(origins = ["*"])
class SearchController(private val searchService: SearchService) {

    @GetMapping
    fun search(
        @RequestParam(name = "q", defaultValue = "") query: String,
        @RequestParam(required = false) type: String?,
        @RequestParam(required = false) college: String?,
        @RequestParam(required = false) location: String?,
        @RequestParam(required = false) skills: List<String>?,
        @RequestParam(required = false) category: String?,
        @RequestParam(required = false) date: String?,
        @RequestParam(required = false) experience: String?,
        @RequestParam(required = false) opportunityType: String?,
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "20") size: Int,
        @RequestParam(defaultValue = "relevance") sort: String
    ): ResponseEntity<ApiResponse<GlobalSearchResponse>> {
        val params = SearchFilterParams(
            query = query,
            type = type,
            college = college,
            location = location,
            skills = skills,
            category = category,
            date = date,
            experience = experience,
            opportunityType = opportunityType,
            page = page,
            size = size,
            sort = sort
        )
        val result = searchService.search(params)
        return ResponseEntity.ok(ApiResponse.success(result))
    }

    @GetMapping("/autocomplete")
    fun autocomplete(@RequestParam(name = "q", defaultValue = "") query: String): ResponseEntity<ApiResponse<List<AutocompleteSuggestion>>> {
        val suggestions = searchService.autocomplete(query)
        return ResponseEntity.ok(ApiResponse.success(suggestions))
    }
}
