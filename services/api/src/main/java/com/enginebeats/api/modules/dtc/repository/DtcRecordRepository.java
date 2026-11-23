package com.enginebeats.api.modules.dtc.repository;

import com.enginebeats.api.modules.dtc.entity.DtcRecordEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface DtcRecordRepository extends JpaRepository<DtcRecordEntity, UUID> {
    List<DtcRecordEntity> findByVehicleIdAndUserIdOrderByDetectedAtDesc(UUID vehicleId, String userId);
    void deleteByVehicleIdAndUserId(UUID vehicleId, String userId);
}
