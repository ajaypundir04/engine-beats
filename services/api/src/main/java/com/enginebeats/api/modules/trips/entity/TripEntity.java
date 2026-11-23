package com.enginebeats.api.modules.trips.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "trips")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TripEntity {

    @Id
    private UUID id;

    @Column(name = "vehicle_id", nullable = false)
    private UUID vehicleId;

    @Column(name = "user_id", nullable = false)
    private String userId;

    @Column(length = 150)
    private String title;

    @Column(name = "started_at", nullable = false)
    private Instant startedAt;

    @Column(name = "ended_at")
    private Instant endedAt;

    @Column(name = "distance_km")
    private Double distanceKm;

    @Column(name = "max_speed_kmh")
    private Double maxSpeedKmh;

    @Column(name = "avg_speed_kmh")
    private Double avgSpeedKmh;

    @Column(name = "fuel_consumed_liters")
    private Double fuelConsumedLiters;

    @Column(nullable = false, length = 20)
    private String status;

    @PrePersist
    public void prePersist() {
        if (id == null) {
            id = UUID.randomUUID();
        }
        if (startedAt == null) {
            startedAt = Instant.now();
        }
        if (status == null) {
            status = "IN_PROGRESS";
        }
        if (distanceKm == null) distanceKm = 0.0;
        if (maxSpeedKmh == null) maxSpeedKmh = 0.0;
        if (avgSpeedKmh == null) avgSpeedKmh = 0.0;
        if (fuelConsumedLiters == null) fuelConsumedLiters = 0.0;
    }
}
