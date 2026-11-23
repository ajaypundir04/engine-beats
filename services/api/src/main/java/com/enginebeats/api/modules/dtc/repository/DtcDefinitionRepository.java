package com.enginebeats.api.modules.dtc.repository;

import com.enginebeats.api.modules.dtc.entity.DtcDefinitionEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface DtcDefinitionRepository extends JpaRepository<DtcDefinitionEntity, String> {
    Optional<DtcDefinitionEntity> findByCodeIgnoreCase(String code);
}
