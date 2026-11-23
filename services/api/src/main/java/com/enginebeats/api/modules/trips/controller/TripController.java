package com.enginebeats.api.modules.trips.controller;

import com.enginebeats.api.common.security.SecurityUtils;
import com.enginebeats.api.modules.trips.dto.EndTripRequest;
import com.enginebeats.api.modules.trips.dto.StartTripRequest;
import com.enginebeats.api.modules.trips.dto.TripResponse;
import com.enginebeats.api.modules.trips.service.TripService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/trips")
@RequiredArgsConstructor
@Tag(name = "Trips", description = "Driving trips and summaries")
public class TripController {

    private final TripService tripService;

    @GetMapping
    @Operation(summary = "Get driving trips for user")
    public ResponseEntity<List<TripResponse>> listTrips(@RequestParam(required = false) UUID vehicleId) {
        String userId = SecurityUtils.getCurrentUserId();
        return ResponseEntity.ok(tripService.getTrips(userId, vehicleId));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get single trip details")
    public ResponseEntity<TripResponse> getTrip(@PathVariable UUID id) {
        String userId = SecurityUtils.getCurrentUserId();
        return ResponseEntity.ok(tripService.getTripById(id, userId));
    }

    @PostMapping("/start")
    @Operation(summary = "Start a new driving trip")
    public ResponseEntity<TripResponse> startTrip(@Valid @RequestBody StartTripRequest request) {
        String userId = SecurityUtils.getCurrentUserId();
        return ResponseEntity.status(HttpStatus.CREATED).body(tripService.startTrip(request, userId));
    }

    @PostMapping("/{id}/end")
    @Operation(summary = "End an ongoing trip")
    public ResponseEntity<TripResponse> endTrip(@PathVariable UUID id, @RequestBody(required = false) EndTripRequest request) {
        String userId = SecurityUtils.getCurrentUserId();
        return ResponseEntity.ok(tripService.endTrip(id, request, userId));
    }
}
