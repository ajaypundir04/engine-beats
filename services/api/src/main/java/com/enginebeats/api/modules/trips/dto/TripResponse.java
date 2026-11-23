package com.enginebeats.api.modules.trips.dto;

import com.enginebeats.api.modules.trips.entity.TripEntity;

import java.time.Instant;
import java.util.UUID;

public record TripResponse(
        UUID id,
        UUID vehicleId,
        String userId,
        String title,
        Instant startedAt,
        Instant endedAt,
        Double distanceKm,
        Double maxSpeedKmh,
        Double avgSpeedKmh,
        Double fuelConsumedLiters,
        String status
) {
    public static TripResponse fromEntity(TripEntity entity) {
        return new TripResponse(
                entity.getId(),
                entity.getVehicleId(),
                entity.getUserId(),
                entity.getTitle(),
                entity.getStartedAt(),
                entity.getEndedAt(),
                entity.getDistanceKm(),
                entity.getMaxSpeedKmh(),
                entity.getAvgSpeedKmh(),
                entity.getFuelConsumedLiters(),
                entity.getStatus()
        );
    }
}
