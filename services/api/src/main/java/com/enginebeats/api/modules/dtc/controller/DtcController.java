package com.enginebeats.api.modules.dtc.controller;

import com.enginebeats.api.common.security.SecurityUtils;
import com.enginebeats.api.modules.dtc.dto.DtcLookupResponse;
import com.enginebeats.api.modules.dtc.dto.DtcRecordRequest;
import com.enginebeats.api.modules.dtc.dto.DtcRecordResponse;
import com.enginebeats.api.modules.dtc.service.DtcService;
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
@RequestMapping("/api/v1/dtc")
@RequiredArgsConstructor
@Tag(name = "Diagnostics", description = "OBD-II Diagnostic Trouble Codes (DTCs)")
public class DtcController {

    private final DtcService dtcService;

    @PostMapping("/records")
    @Operation(summary = "Record detected DTC trouble codes from OBD scan")
    public ResponseEntity<List<DtcRecordResponse>> recordDtcs(@Valid @RequestBody DtcRecordRequest request) {
        String userId = SecurityUtils.getCurrentUserId();
        return ResponseEntity.status(HttpStatus.CREATED).body(dtcService.recordDtcs(request, userId));
    }

    @GetMapping("/records/vehicle/{vehicleId}")
    @Operation(summary = "Get recorded DTC history for a vehicle")
    public ResponseEntity<List<DtcRecordResponse>> getRecords(@PathVariable UUID vehicleId) {
        String userId = SecurityUtils.getCurrentUserId();
        return ResponseEntity.ok(dtcService.getDtcRecordsForVehicle(vehicleId, userId));
    }

    @GetMapping("/lookup/{code}")
    @Operation(summary = "Look up standard SAE DTC code description and common causes")
    public ResponseEntity<DtcLookupResponse> lookupCode(@PathVariable String code) {
        return ResponseEntity.ok(dtcService.lookupDefinition(code));
    }

    @DeleteMapping("/records/vehicle/{vehicleId}")
    @Operation(summary = "Clear recorded DTC history for a vehicle")
    public ResponseEntity<Void> clearRecords(@PathVariable UUID vehicleId) {
        String userId = SecurityUtils.getCurrentUserId();
        dtcService.clearDtcHistory(vehicleId, userId);
        return ResponseEntity.noContent().build();
    }
}
