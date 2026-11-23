package com.enginebeats.api.modules.telemetry.controller;

import com.enginebeats.api.common.security.SecurityUtils;
import com.enginebeats.api.modules.telemetry.dto.TelemetryBatchRequest;
import com.enginebeats.api.modules.telemetry.dto.TelemetryBatchResponse;
import com.enginebeats.api.modules.telemetry.dto.TelemetryReadingDto;
import com.enginebeats.api.modules.telemetry.service.TelemetryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/telemetry")
@RequiredArgsConstructor
@Tag(name = "Telemetry", description = "High-throughput batch ingestion of OBD-II telemetry readings")
public class TelemetryController {

    private final TelemetryService telemetryService;

    @PostMapping("/batches")
    @Operation(summary = "Ingest a batch of OBD telemetry readings (idempotent)")
    public ResponseEntity<TelemetryBatchResponse> ingestBatch(@Valid @RequestBody TelemetryBatchRequest request) {
        String userId = SecurityUtils.getCurrentUserId();
        return ResponseEntity.ok(telemetryService.processBatch(request, userId));
    }

    @GetMapping("/vehicles/{vehicleId}/latest")
    @Operation(summary = "Get latest snapshot reading for a vehicle")
    public ResponseEntity<TelemetryReadingDto> getLatestReading(@PathVariable UUID vehicleId) {
        String userId = SecurityUtils.getCurrentUserId();
        return ResponseEntity.ok(telemetryService.getLatestReading(vehicleId, userId));
    }
}
