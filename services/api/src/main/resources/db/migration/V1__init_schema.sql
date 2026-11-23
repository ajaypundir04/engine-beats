-- EngineBeats PostgreSQL Schema Initialization

CREATE TABLE IF NOT EXISTS vehicles (
    id UUID PRIMARY KEY,
    user_id VARCHAR(100) NOT NULL,
    vin VARCHAR(17) NOT NULL,
    make VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    year INT NOT NULL,
    nickname VARCHAR(100),
    protocol VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_vehicles_user_id ON vehicles(user_id);

CREATE TABLE IF NOT EXISTS trips (
    id UUID PRIMARY KEY,
    vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    user_id VARCHAR(100) NOT NULL,
    title VARCHAR(150),
    started_at TIMESTAMP WITH TIME ZONE NOT NULL,
    ended_at TIMESTAMP WITH TIME ZONE,
    distance_km DOUBLE PRECISION DEFAULT 0.0,
    max_speed_kmh DOUBLE PRECISION DEFAULT 0.0,
    avg_speed_kmh DOUBLE PRECISION DEFAULT 0.0,
    fuel_consumed_liters DOUBLE PRECISION DEFAULT 0.0,
    status VARCHAR(20) NOT NULL DEFAULT 'IN_PROGRESS'
);

CREATE INDEX IF NOT EXISTS idx_trips_vehicle_id ON trips(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_trips_user_id ON trips(user_id);

CREATE TABLE IF NOT EXISTS telemetry_batches (
    batch_id UUID PRIMARY KEY,
    vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    user_id VARCHAR(100) NOT NULL,
    record_count INT NOT NULL,
    received_at TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_telemetry_batches_vehicle_id ON telemetry_batches(vehicle_id);

CREATE TABLE IF NOT EXISTS telemetry_readings (
    id BIGSERIAL PRIMARY KEY,
    batch_id UUID NOT NULL REFERENCES telemetry_batches(batch_id) ON DELETE CASCADE,
    vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    trip_id UUID REFERENCES trips(id) ON DELETE SET NULL,
    recorded_at TIMESTAMP WITH TIME ZONE NOT NULL,
    rpm DOUBLE PRECISION,
    speed_kmh DOUBLE PRECISION,
    coolant_temp_c INT,
    throttle_pos_pct DOUBLE PRECISION,
    fuel_level_pct DOUBLE PRECISION,
    maf_gps DOUBLE PRECISION,
    battery_voltage DOUBLE PRECISION,
    ambient_temp_c INT,
    engine_load_pct DOUBLE PRECISION
);

CREATE INDEX IF NOT EXISTS idx_telemetry_readings_vehicle_time ON telemetry_readings(vehicle_id, recorded_at DESC);
CREATE INDEX IF NOT EXISTS idx_telemetry_readings_trip_id ON telemetry_readings(trip_id);

CREATE TABLE IF NOT EXISTS dtc_definitions (
    code VARCHAR(10) PRIMARY KEY,
    system VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    severity VARCHAR(20) NOT NULL,
    common_causes TEXT
);

CREATE TABLE IF NOT EXISTS dtc_records (
    id UUID PRIMARY KEY,
    vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    user_id VARCHAR(100) NOT NULL,
    code VARCHAR(10) NOT NULL,
    description TEXT,
    severity VARCHAR(20) NOT NULL,
    mil_active BOOLEAN DEFAULT TRUE,
    detected_at TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_dtc_records_vehicle ON dtc_records(vehicle_id, detected_at DESC);

CREATE TABLE IF NOT EXISTS user_entitlements (
    id UUID PRIMARY KEY,
    user_id VARCHAR(100) NOT NULL UNIQUE,
    is_premium BOOLEAN NOT NULL DEFAULT FALSE,
    plan VARCHAR(50),
    expires_at TIMESTAMP WITH TIME ZONE,
    stripe_customer_id VARCHAR(100),
    stripe_subscription_id VARCHAR(100),
    source VARCHAR(30) NOT NULL DEFAULT 'WEB',
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_user_entitlements_user_id ON user_entitlements(user_id);
