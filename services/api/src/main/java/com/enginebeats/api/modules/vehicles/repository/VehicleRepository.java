package com.enginebeats.api.modules.vehicles.repository;

import com.enginebeats.api.modules.vehicles.entity.VehicleEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface VehicleRepository extends JpaRepository<VehicleEntity, UUID> {
    List<VehicleEntity> findByUserIdOrderByCreatedAtDesc(String userId);
    Optional<VehicleEntity> findByIdAndUserId(UUID id, String userId);
}
