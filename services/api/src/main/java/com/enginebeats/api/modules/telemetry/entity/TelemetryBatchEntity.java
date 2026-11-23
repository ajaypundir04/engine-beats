package com.enginebeats.api.modules.telemetry.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "telemetry_batches")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TelemetryBatchEntity {

    @Id
    @Column(name = "batch_id", nullable = false)
    private UUID batchId;

    @Column(name = "vehicle_id", nullable = false)
    private UUID vehicleId;

    @Column(name = "user_id", nullable = false)
    private String userId;

    @Column(name = "record_count", nullable = false)
    private int recordCount;

    @Column(name = "received_at", nullable = false)
    private Instant receivedAt;

    @PrePersist
    public void prePersist() {
        if (receivedAt == null) {
            receivedAt = Instant.now();
        }
    }
}
