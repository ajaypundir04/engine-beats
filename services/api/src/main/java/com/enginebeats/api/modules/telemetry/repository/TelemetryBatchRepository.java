package com.enginebeats.api.modules.telemetry.repository;

import com.enginebeats.api.modules.telemetry.entity.TelemetryBatchEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface TelemetryBatchRepository extends JpaRepository<TelemetryBatchEntity, UUID> {
}
