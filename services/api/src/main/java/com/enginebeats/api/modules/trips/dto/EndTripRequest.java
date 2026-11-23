package com.enginebeats.api.modules.trips.dto;

public record EndTripRequest(
        Double distanceKm,
        Double maxSpeedKmh,
        Double avgSpeedKmh,
        Double fuelConsumedLiters
) {
}
