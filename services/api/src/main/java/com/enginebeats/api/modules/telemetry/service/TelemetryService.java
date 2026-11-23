package com.enginebeats.api.modules.telemetry.service;

import com.enginebeats.api.common.exception.ResourceNotFoundException;
import com.enginebeats.api.modules.telemetry.dto.TelemetryBatchRequest;
import com.enginebeats.api.modules.telemetry.dto.TelemetryBatchResponse;
import com.enginebeats.api.modules.telemetry.dto.TelemetryReadingDto;
import com.enginebeats.api.modules.telemetry.entity.TelemetryBatchEntity;
import com.enginebeats.api.modules.telemetry.entity.TelemetryReadingEntity;
import com.enginebeats.api.modules.telemetry.repository.TelemetryBatchRepository;
import com.enginebeats.api.modules.telemetry.repository.TelemetryReadingRepository;
import com.enginebeats.api.modules.vehicles.repository.VehicleRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class TelemetryService {

    private final TelemetryBatchRepository batchRepository;
    private final TelemetryReadingRepository readingRepository;
    private final VehicleRepository vehicleRepository;

    @Transactional
    public TelemetryBatchResponse processBatch(TelemetryBatchRequest request, String userId) {
        // 1. Idempotency Check: if batch was already ingested, skip processing
        if (batchRepository.existsById(request.batchId())) {
            log.info("Batch {} was already processed. Returning cached success (idempotent).", request.batchId());
            return new TelemetryBatchResponse(request.batchId(), 0, "ALREADY_PROCESSED");
        }

        // 2. Validate Vehicle Ownership
        vehicleRepository.findByIdAndUserId(request.vehicleId(), userId)
                .orElseThrow(() -> new ResourceNotFoundException("Vehicle not found or unauthorized: " + request.vehicleId()));

        // 3. Persist Batch Metadata
        TelemetryBatchEntity batch = TelemetryBatchEntity.builder()
                .batchId(request.batchId())
                .vehicleId(request.vehicleId())
                .userId(userId)
                .recordCount(request.readings().size())
                .receivedAt(Instant.now())
                .build();
        batchRepository.save(batch);

        // 4. Batch Persist Telemetry Readings
        List<TelemetryReadingEntity> entities = request.readings().stream().map(dto ->
                TelemetryReadingEntity.builder()
                        .batchId(request.batchId())
                        .vehicleId(request.vehicleId())
                        .tripId(request.tripId())
                        .recordedAt(dto.timestamp())
                        .rpm(dto.rpm())
                        .speedKmh(dto.speedKmh())
                        .coolantTempC(dto.coolantTempC())
                        .throttlePosPct(dto.throttlePosPct())
                        .fuelLevelPct(dto.fuelLevelPct())
                        .mafGps(dto.mafGps())
                        .batteryVoltage(dto.batteryVoltage())
                        .ambientTempC(dto.ambientTempC())
                        .engineLoadPct(dto.engineLoadPct())
                        .build()
        ).toList();

        readingRepository.saveAll(entities);
        log.info("Successfully ingested telemetry batch {} with {} readings for vehicle {}",
                request.batchId(), entities.size(), request.vehicleId());

        return new TelemetryBatchResponse(request.batchId(), entities.size(), "PROCESSED");
    }

    @Transactional(readOnly = true)
    public TelemetryReadingDto getLatestReading(UUID vehicleId, String userId) {
        vehicleRepository.findByIdAndUserId(vehicleId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("Vehicle not found or unauthorized: " + vehicleId));

        return readingRepository.findFirstByVehicleIdOrderByRecordedAtDesc(vehicleId)
                .map(TelemetryReadingDto::fromEntity)
                .orElseThrow(() -> new ResourceNotFoundException("No telemetry readings found for vehicle " + vehicleId));
    }
}
