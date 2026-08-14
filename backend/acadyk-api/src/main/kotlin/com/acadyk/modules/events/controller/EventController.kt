package com.acadyk.modules.events.controller

import com.acadyk.common.ApiResponse
import com.acadyk.common.PageResponse
import com.acadyk.modules.events.dto.CreateEventRequest
import com.acadyk.modules.events.dto.EventResponse
import com.acadyk.modules.events.service.EventService
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/v1/events")
@CrossOrigin(origins = ["*"])
class EventController(private val eventService: EventService) {

    @GetMapping
    fun getEvents(
        @RequestParam(required = false) eventType: String?,
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "20") size: Int
    ): ResponseEntity<ApiResponse<PageResponse<EventResponse>>> {
        val result = eventService.getEvents(eventType, page, size)
        return ResponseEntity.ok(ApiResponse.success(result))
    }

    @GetMapping("/{id}")
    fun getEventById(@PathVariable id: String): ResponseEntity<ApiResponse<EventResponse>> {
        val event = eventService.getEventById(id)
        return ResponseEntity.ok(ApiResponse.success(event))
    }

    @PostMapping
    fun createEvent(@Valid @RequestBody request: CreateEventRequest): ResponseEntity<ApiResponse<EventResponse>> {
        val event = eventService.createEvent(request)
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(ApiResponse.success(event, "Event created successfully"))
    }

    @PostMapping("/{id}/register")
    fun register(@PathVariable id: String): ResponseEntity<ApiResponse<Map<String, Boolean>>> {
        val success = eventService.registerForEvent(id)
        return ResponseEntity.ok(ApiResponse.success(mapOf("registered" to success)))
    }
}
