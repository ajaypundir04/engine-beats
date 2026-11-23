package com.enginebeats.api.modules.telemetry.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "telemetry_readings")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TelemetryReadingEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "batch_id", nullable = false)
    private UUID batchId;

    @Column(name = "vehicle_id", nullable = false)
    private UUID vehicleId;

    @Column(name = "trip_id")
    private UUID tripId;

    @Column(name = "recorded_at", nullable = false)
    private Instant recordedAt;

    private Double rpm;

    @Column(name = "speed_kmh")
    private Double speedKmh;

    @Column(name = "coolant_temp_c")
    private Integer coolantTempC;

    @Column(name = "throttle_pos_pct")
    private Double throttlePosPct;

    @Column(name = "fuel_level_pct")
    private Double fuelLevelPct;

    @Column(name = "maf_gps")
    private Double mafGps;

    @Column(name = "battery_voltage")
    private Double batteryVoltage;

    @Column(name = "ambient_temp_c")
    private Integer ambientTempC;

    @Column(name = "engine_load_pct")
    private Double engineLoadPct;
}
