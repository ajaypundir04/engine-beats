package com.enginebeats.api.modules.vehicles.dto;

import com.enginebeats.api.modules.vehicles.entity.VehicleEntity;

import java.time.Instant;
import java.util.UUID;

public record VehicleResponse(
        UUID id,
        String userId,
        String vin,
        String make,
        String model,
        int year,
        String nickname,
        String protocol,
        Instant createdAt
) {
    public static VehicleResponse fromEntity(VehicleEntity entity) {
        return new VehicleResponse(
                entity.getId(),
                entity.getUserId(),
                entity.getVin(),
                entity.getMake(),
                entity.getModel(),
                entity.getYear(),
                entity.getNickname(),
                entity.getProtocol(),
                entity.getCreatedAt()
        );
    }
}
