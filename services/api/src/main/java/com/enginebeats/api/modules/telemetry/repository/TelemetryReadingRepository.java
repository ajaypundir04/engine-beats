package com.enginebeats.api.modules.telemetry.repository;

import com.enginebeats.api.modules.telemetry.entity.TelemetryReadingEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface TelemetryReadingRepository extends JpaRepository<TelemetryReadingEntity, Long> {
    Optional<TelemetryReadingEntity> findFirstByVehicleIdOrderByRecordedAtDesc(UUID vehicleId);
    List<TelemetryReadingEntity> findByTripIdOrderByRecordedAtAsc(UUID tripId);
}
