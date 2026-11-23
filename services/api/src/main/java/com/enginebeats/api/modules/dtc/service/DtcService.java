package com.enginebeats.api.modules.dtc.service;

import com.enginebeats.api.common.exception.ResourceNotFoundException;
import com.enginebeats.api.modules.dtc.dto.DtcLookupResponse;
import com.enginebeats.api.modules.dtc.dto.DtcRecordRequest;
import com.enginebeats.api.modules.dtc.dto.DtcRecordResponse;
import com.enginebeats.api.modules.dtc.entity.DtcDefinitionEntity;
import com.enginebeats.api.modules.dtc.entity.DtcRecordEntity;
import com.enginebeats.api.modules.dtc.repository.DtcDefinitionRepository;
import com.enginebeats.api.modules.dtc.repository.DtcRecordRepository;
import com.enginebeats.api.modules.vehicles.repository.VehicleRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class DtcService {

    private final DtcRecordRepository recordRepository;
    private final DtcDefinitionRepository definitionRepository;
    private final VehicleRepository vehicleRepository;

    @Transactional
    public List<DtcRecordResponse> recordDtcs(DtcRecordRequest request, String userId) {
        vehicleRepository.findByIdAndUserId(request.vehicleId(), userId)
                .orElseThrow(() -> new ResourceNotFoundException("Vehicle not found or unauthorized: " + request.vehicleId()));

        List<DtcRecordEntity> records = new ArrayList<>();
        Instant now = Instant.now();

        for (String rawCode : request.codes()) {
            String code = rawCode.trim().toUpperCase();
            Optional<DtcDefinitionEntity> definition = definitionRepository.findByCodeIgnoreCase(code);

            String description = definition.map(DtcDefinitionEntity::getDescription)
                    .orElse("Diagnostic Trouble Code " + code);
            String severity = definition.map(DtcDefinitionEntity::getSeverity)
                    .orElse(code.startsWith("P03") ? "CRITICAL" : "WARNING");

            DtcRecordEntity record = DtcRecordEntity.builder()
                    .vehicleId(request.vehicleId())
                    .userId(userId)
                    .code(code)
                    .description(description)
                    .severity(severity)
                    .milActive(request.milStatus() != null ? request.milStatus() : true)
                    .detectedAt(now)
                    .build();

            records.add(record);
        }

        List<DtcRecordEntity> saved = recordRepository.saveAll(records);
        log.info("Saved {} DTC records for vehicle {}", saved.size(), request.vehicleId());
        return saved.stream().map(DtcRecordResponse::fromEntity).toList();
    }

    @Transactional(readOnly = true)
    public List<DtcRecordResponse> getDtcRecordsForVehicle(UUID vehicleId, String userId) {
        vehicleRepository.findByIdAndUserId(vehicleId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("Vehicle not found or unauthorized: " + vehicleId));

        return recordRepository.findByVehicleIdAndUserIdOrderByDetectedAtDesc(vehicleId, userId)
                .stream()
                .map(DtcRecordResponse::fromEntity)
                .toList();
    }

    @Transactional(readOnly = true)
    public DtcLookupResponse lookupDefinition(String code) {
        DtcDefinitionEntity def = definitionRepository.findByCodeIgnoreCase(code.trim().toUpperCase())
                .orElseThrow(() -> new ResourceNotFoundException("No definition found for DTC code: " + code));
        return DtcLookupResponse.fromEntity(def);
    }

    @Transactional
    public void clearDtcHistory(UUID vehicleId, String userId) {
        vehicleRepository.findByIdAndUserId(vehicleId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("Vehicle not found or unauthorized: " + vehicleId));
        recordRepository.deleteByVehicleIdAndUserId(vehicleId, userId);
        log.info("Cleared DTC history for vehicle {}", vehicleId);
    }
}
