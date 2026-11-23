package com.enginebeats.api.modules.trips.repository;

import com.enginebeats.api.modules.trips.entity.TripEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface TripRepository extends JpaRepository<TripEntity, UUID> {
    List<TripEntity> findByUserIdOrderByStartedAtDesc(String userId);
    List<TripEntity> findByUserIdAndVehicleIdOrderByStartedAtDesc(String userId, UUID vehicleId);
    Optional<TripEntity> findByIdAndUserId(UUID id, String userId);
}
