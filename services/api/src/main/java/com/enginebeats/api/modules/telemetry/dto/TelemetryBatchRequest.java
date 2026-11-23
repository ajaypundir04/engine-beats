package com.enginebeats.api.modules.telemetry.dto;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;

import java.util.List;
import java.util.UUID;

public record TelemetryBatchRequest(
        @NotNull UUID batchId,
        @NotNull UUID vehicleId,
        UUID tripId,
        @NotNull @NotEmpty List<TelemetryReadingDto> readings
) {
}
