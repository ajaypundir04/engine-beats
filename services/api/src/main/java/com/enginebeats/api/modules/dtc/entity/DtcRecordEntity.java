package com.enginebeats.api.modules.dtc.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "dtc_records")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DtcRecordEntity {

    @Id
    private UUID id;

    @Column(name = "vehicle_id", nullable = false)
    private UUID vehicleId;

    @Column(name = "user_id", nullable = false)
    private String userId;

    @Column(nullable = false, length = 10)
    private String code;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(nullable = false, length = 20)
    private String severity;

    @Column(name = "mil_active")
    private Boolean milActive;

    @Column(name = "detected_at", nullable = false)
    private Instant detectedAt;

    @PrePersist
    public void prePersist() {
        if (id == null) {
            id = UUID.randomUUID();
        }
        if (detectedAt == null) {
            detectedAt = Instant.now();
        }
        if (milActive == null) {
            milActive = true;
        }
    }
}
