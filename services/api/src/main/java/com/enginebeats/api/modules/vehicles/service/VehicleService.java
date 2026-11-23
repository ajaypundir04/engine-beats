package com.enginebeats.api.modules.vehicles.service;

import com.enginebeats.api.common.exception.ResourceNotFoundException;
import com.enginebeats.api.modules.billing.service.BillingService;
import com.enginebeats.api.modules.vehicles.dto.CreateVehicleRequest;
import com.enginebeats.api.modules.vehicles.dto.VehicleResponse;
import com.enginebeats.api.modules.vehicles.entity.VehicleEntity;
import com.enginebeats.api.modules.vehicles.repository.VehicleRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class VehicleService {

    private final VehicleRepository vehicleRepository;
    private final BillingService billingService;

    @Transactional(readOnly = true)
    public List<VehicleResponse> getVehiclesForUser(String userId) {
        return vehicleRepository.findByUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .map(VehicleResponse::fromEntity)
                .toList();
    }

    @Transactional(readOnly = true)
    public VehicleResponse getVehicleById(UUID id, String userId) {
        VehicleEntity vehicle = vehicleRepository.findByIdAndUserId(id, userId)
                .orElseThrow(() -> new ResourceNotFoundException("Vehicle not found with id: " + id));
        return VehicleResponse.fromEntity(vehicle);
    }

    @Transactional
    public VehicleResponse createVehicle(CreateVehicleRequest request, String userId) {
        List<VehicleEntity> existing = vehicleRepository.findByUserIdOrderByCreatedAtDesc(userId);
        if (!existing.isEmpty() && !billingService.isUserPremium(userId)) {
            throw new IllegalArgumentException("Free tier allows only 1 registered vehicle. Upgrade to EngineBeats Pro for multi-vehicle support.");
        }

        VehicleEntity vehicle = VehicleEntity.builder()
                .userId(userId)
                .vin(request.vin().toUpperCase().trim())
                .make(request.make().trim())
                .model(request.model().trim())
                .year(request.year())
                .nickname(request.nickname())
                .protocol(request.protocol() != null ? request.protocol() : "ISO 15765-4 (CAN 11/500)")
                .build();

        VehicleEntity saved = vehicleRepository.save(vehicle);
        return VehicleResponse.fromEntity(saved);
    }

    @Transactional
    public void deleteVehicle(UUID id, String userId) {
        VehicleEntity vehicle = vehicleRepository.findByIdAndUserId(id, userId)
                .orElseThrow(() -> new ResourceNotFoundException("Vehicle not found with id: " + id));
        vehicleRepository.delete(vehicle);
    }
}
