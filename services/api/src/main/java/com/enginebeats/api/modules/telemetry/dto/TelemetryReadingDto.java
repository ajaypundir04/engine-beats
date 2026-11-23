package com.enginebeats.api.modules.telemetry.dto;

import com.enginebeats.api.modules.telemetry.entity.TelemetryReadingEntity;
import jakarta.validation.constraints.NotNull;

import java.time.Instant;

public record TelemetryReadingDto(
        @NotNull Instant timestamp,
        Double rpm,
        Double speedKmh,
        Integer coolantTempC,
        Double throttlePosPct,
        Double fuelLevelPct,
        Double mafGps,
        Double batteryVoltage,
        Integer ambientTempC,
        Double engineLoadPct
) {
    public static TelemetryReadingDto fromEntity(TelemetryReadingEntity entity) {
        return new TelemetryReadingDto(
                entity.getRecordedAt(),
                entity.getRpm(),
                entity.getSpeedKmh(),
                entity.getCoolantTempC(),
                entity.getThrottlePosPct(),
                entity.getFuelLevelPct(),
                entity.getMafGps(),
                entity.getBatteryVoltage(),
                entity.getAmbientTempC(),
                entity.getEngineLoadPct()
        );
    }
}
