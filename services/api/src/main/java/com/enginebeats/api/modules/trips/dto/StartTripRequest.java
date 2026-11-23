package com.enginebeats.api.modules.trips.dto;

import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public record StartTripRequest(
        @NotNull UUID vehicleId,
        String title
) {
}
