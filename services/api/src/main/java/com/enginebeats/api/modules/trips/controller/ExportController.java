package com.enginebeats.api.modules.trips.controller;

import com.enginebeats.api.common.security.SecurityUtils;
import com.enginebeats.api.modules.billing.service.BillingService;
import com.enginebeats.api.modules.trips.dto.TripResponse;
import com.enginebeats.api.modules.trips.service.TripService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/exports")
@RequiredArgsConstructor
@Tag(name = "Exports", description = "Data export service (Premium)")
public class ExportController {

    private final TripService tripService;
    private final BillingService billingService;

    @GetMapping(value = "/trips.csv", produces = "text/csv")
    @Operation(summary = "Export trip records as CSV (Requires PREMIUM entitlement)")
    public ResponseEntity<String> exportTripsCsv() {
        String userId = SecurityUtils.getCurrentUserId();
        if (!billingService.isUserPremium(userId)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body("CSV export requires an active EngineBeats Pro subscription.");
        }

        List<TripResponse> trips = tripService.getTrips(userId, null);
        StringBuilder csv = new StringBuilder();
        csv.append("Trip ID,Vehicle ID,Title,Started At,Ended At,Distance (km),Max Speed (km/h),Avg Speed (km/h),Fuel (L)\n");

        for (TripResponse t : trips) {
            csv.append(String.format("\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",%.2f,%.2f,%.2f,%.2f\n",
                    t.id(),
                    t.vehicleId(),
                    t.title() != null ? t.title().replace("\"", "\"\"") : "",
                    t.startedAt(),
                    t.endedAt() != null ? t.endedAt().toString() : "",
                    t.distanceKm() != null ? t.distanceKm() : 0.0,
                    t.maxSpeedKmh() != null ? t.maxSpeedKmh() : 0.0,
                    t.avgSpeedKmh() != null ? t.avgSpeedKmh() : 0.0,
                    t.fuelConsumedLiters() != null ? t.fuelConsumedLiters() : 0.0
            ));
        }

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"enginebeats_trips.csv\"")
                .contentType(MediaType.parseMediaType("text/csv"))
                .body(csv.toString());
    }
}
