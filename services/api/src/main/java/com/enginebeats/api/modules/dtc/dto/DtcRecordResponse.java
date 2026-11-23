package com.enginebeats.api.modules.dtc.dto;

import com.enginebeats.api.modules.dtc.entity.DtcRecordEntity;

import java.time.Instant;
import java.util.UUID;

public record DtcRecordResponse(
        UUID id,
        UUID vehicleId,
        String code,
        String description,
        String severity,
        boolean milActive,
        Instant detectedAt
) {
    public static DtcRecordResponse fromEntity(DtcRecordEntity entity) {
        return new DtcRecordResponse(
                entity.getId(),
                entity.getVehicleId(),
                entity.getCode(),
                entity.getDescription(),
                entity.getSeverity(),
                Boolean.TRUE.equals(entity.getMilActive()),
                entity.getDetectedAt()
        );
    }
}
