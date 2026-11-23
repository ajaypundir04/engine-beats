package com.enginebeats.api.modules.vehicles.controller;

import com.enginebeats.api.common.security.SecurityUtils;
import com.enginebeats.api.modules.vehicles.dto.CreateVehicleRequest;
import com.enginebeats.api.modules.vehicles.dto.VehicleResponse;
import com.enginebeats.api.modules.vehicles.service.VehicleService;
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
@RequestMapping("/api/v1/vehicles")
@RequiredArgsConstructor
@Tag(name = "Vehicles", description = "Vehicle profiles and protocols")
public class VehicleController {

    private final VehicleService vehicleService;

    @GetMapping
    @Operation(summary = "List all vehicles owned by user")
    public ResponseEntity<List<VehicleResponse>> listVehicles() {
        String userId = SecurityUtils.getCurrentUserId();
        return ResponseEntity.ok(vehicleService.getVehiclesForUser(userId));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get vehicle details by ID")
    public ResponseEntity<VehicleResponse> getVehicle(@PathVariable UUID id) {
        String userId = SecurityUtils.getCurrentUserId();
        return ResponseEntity.ok(vehicleService.getVehicleById(id, userId));
    }

    @PostMapping
    @Operation(summary = "Register a new vehicle")
    public ResponseEntity<VehicleResponse> createVehicle(@Valid @RequestBody CreateVehicleRequest request) {
        String userId = SecurityUtils.getCurrentUserId();
        return ResponseEntity.status(HttpStatus.CREATED).body(vehicleService.createVehicle(request, userId));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete vehicle by ID")
    public ResponseEntity<Void> deleteVehicle(@PathVariable UUID id) {
        String userId = SecurityUtils.getCurrentUserId();
        vehicleService.deleteVehicle(id, userId);
        return ResponseEntity.noContent().build();
    }
}
