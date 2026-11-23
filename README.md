# EngineBeats - Connected Car Telemetry & OBD-II Diagnostics Platform

EngineBeats is an end-to-end connected vehicle platform featuring:
- **Mobile App (`/apps/mobile`)**: Flutter client with Bluetooth LE & WiFi OBD-II ELM327 dongle support, offline batch buffering, real-time gauges, and DTC diagnostics.
- **Protocol Package (`/packages/obd-core`)**: Pure Dart ELM327 AT command engine, standard Mode 01 PID decoder, and Mode 03/07 DTC parser.
- **Backend API (`/services/api`)**: Spring Boot modular monolith with Spring Security OAuth2 (Keycloak/OIDC), idempotent batch telemetry ingestion, vehicle management, trip tracking, and billing/entitlements.
- **Auth Service (`/services/auth`)**: Keycloak realm configuration as code with OIDC + PKCE support for mobile and web clients.
- **Contract (`/contracts`)**: OpenAPI 3.0 specification serving as single source of truth for clients and backend.
- **Infrastructure (`/infra`)**: OpenTofu/Terraform modular infrastructure supporting free-tier staging (Oracle Cloud Always Free / Aiven) and production deployments.
- **Hardware Simulator (`/tools/elm327-emulator`)**: Python TCP ELM327 car emulator with live driving physics for testing without a vehicle.

---

## Architecture Overview

```
                      ┌───────────────────────────────────────┐
                      │    Flutter Mobile App (iOS/Android)   │
                      │  (Riverpod, Drift SQLite, Dio, AppAuth)│
                      └───────┬───────────────────────┬───────┘
          Bluetooth / WiFi    │                       │ HTTPS (OIDC JWT)
          ELM327 OBD Dongle   │                       ▼
                  ▼           ▼             Cloudflare (DNS, TLS, WAF)
         ┌───────────────────────┐                    │
         │   Vehicle OBD-II Port │                    ▼
         │  or ELM327 Emulator   │           Caddy Reverse Proxy (:80/:443)
         └───────────────────────┘           ├── /auth/*  ──► Keycloak (:8080)
                                             └── /api/*   ──► Spring Boot API (:8081)
                                                                    │
                                            ┌───────────────────────┴───────────────────────┐
                                            ▼                                               ▼
                                   PostgreSQL 16                                 Stripe / RevenueCat
                                 (+TimescaleDB)                                  Webhooks & Checkout
```

---

## Directory Structure

```
.
├── apps/
│   └── mobile/             # Flutter app (iOS / Android)
├── packages/
│   └── obd-core/           # Dart ELM327 & OBD-II PID decoder package
├── services/
│   ├── api/                # Spring Boot modular monolith API
│   └── auth/               # Keycloak realm configuration
├── contracts/              # OpenAPI 3.0 specification
├── infra/
│   ├── modules/            # Terraform modules (network, compute, db, storage, cdn, billing)
│   └── envs/               # Environment configs (dev, staging, prod)
├── tools/
│   └── elm327-emulator/    # Python OBD-II ELM327 TCP socket emulator
├── run-local.sh            # One-command local runner & dummy log generator
├── docker-compose.yml      # Local dev environment
├── Makefile                # Dev convenience commands
└── Caddyfile               # Local proxy configuration
```

---

## Quickstart: Local Development

### 1. Instant Local Run (No Docker required)
To immediately start the car simulator on port 35000 and generate live & dummy telemetry log files:
```bash
./run-local.sh
# Or in background: ./run-local.sh start
# Check status:     ./run-local.sh status
# Stop services:    ./run-local.sh stop
```

This generates realistic test logs in `logs/`:
- `logs/dummy_obd_trip.log`: Realistic raw OBD-II ELM327 command/response session trace.
- `logs/dummy_telemetry.json`: Pre-formatted JSON telemetry batches ready for ingestion testing.
- `logs/enginebeats-local.log`: Real-time streaming log of the vehicle emulator physics.

### 2. Full Containerized Infrastructure
Run all backing services (PostgreSQL, Keycloak, ELM327 car emulator, and Caddy proxy):

```bash
make dev
# Or: docker-compose up -d
```

Service endpoints:
- **API Gateway / Proxy**: `http://localhost:80`
- **Spring Boot API**: `http://localhost:8081` (Swagger UI: `http://localhost:8081/swagger-ui.html`)
- **Keycloak Auth**: `http://localhost:8080` (admin/admin)
- **Postgres DB**: `localhost:5432` (`enginebeats` / `enginebeats_dev`)
- **ELM327 Car Emulator**: `localhost:35000` (TCP socket)

### 2. Run the ELM327 Car Emulator Standalone
You can also run the car emulator directly in Python:
```bash
make emulator
# Connect via nc localhost 35000 or configure the Flutter app to 127.0.0.1:35000
```

### 3. Run and Test the Backend API
```bash
make test-api
make run-api
```

### 4. Run the Mobile App
```bash
cd apps/mobile
flutter pub get
flutter run -d chrome  # or iOS simulator / Android emulator
```
In the app settings, toggle "Use WiFi/TCP Dongle" and connect to `10.0.2.2:35000` (Android emulator) or `127.0.0.1:35000` (iOS simulator / desktop).

---

## Billing & Entitlements

EngineBeats implements a three-channel billing model:
1. **Google Play / Apple App Store**: Processed via RevenueCat SDK or native store receipts.
2. **Web Checkout**: Handled through Stripe Checkout and Stripe Customer Portal.
3. **Backend Entitlements Service**: A single internal table (`user_entitlements`) updated exclusively through cryptographic webhook verification (`/api/v1/billing/webhooks/stripe` and `/api/v1/billing/webhooks/revenuecat`). The mobile app checks `GET /api/v1/billing/entitlements` and never accesses payment credentials directly.

---

## Documentation

- **[System Architecture Guide](ARCHITECTURE.md)**: Comprehensive deep dive into the end-to-end data flow, protocol decoding (`packages/obd-core`), mobile offline buffering, Keycloak OIDC/PKCE security, Spring Boot modular monolith, and TimescaleDB schema.
- **[Future Updates & Technical Roadmap](FUTURE_UPDATES.md)**: Detailed multi-phase roadmap covering native BLE 5.0, sub-second WebSockets, Edge AI predictive misfire detection, Apple CarPlay / Android Auto, and custom ESP32 LTE/GPS hardware.
- **[Homelab 24/7 Hosting Guide](HOMELAB_HOSTING_GUIDE.md)**: Complete step-by-step setup to host the backend and database 24/7 on a dedicated Raspberry Pi 5 or refurbished 1L Mini PC via zero-port-forwarding Cloudflare Tunnels.

---

## Homelab & Self-Hosting Guide

Want to run EngineBeats 24/7 at home on a dedicated low-power machine without using your personal laptop or cloud subscription fees?
Read the comprehensive **[Homelab Hosting Guide](HOMELAB_HOSTING_GUIDE.md)**:
- Hardware comparison: **Raspberry Pi 5 vs. Refurbished 1-Liter Mini PC (ThinkCentre/OptiPlex)**.
- Headless Ubuntu Server 24.04 setup.
- 24/7 background container deployment (`docker-compose up -d`).
- Zero-port-forwarding public access via encrypted **Cloudflare Tunnel** (`api.yourdomain.com`).
- BIOS AC power loss recovery and automated nightly database backups.

---

## Infrastructure & Multi-Region Strategy

- **Homelab / Self-Hosted**: 24/7 low-power Raspberry Pi 5 or 1L Mini PC with Cloudflare Tunnel (see [Homelab Guide](HOMELAB_HOSTING_GUIDE.md)).
- **Dev / Local**: Docker Compose with local PostgreSQL, Keycloak, and ELM327 simulator.
- **Staging / Beta**: Free-tier deployment on Oracle Always Free (Ampere A1 ARM64) or Aiven Managed Postgres + Cloudflare.
- **Production**: Seamless swap to small EU VPS (e.g., Hetzner Cloud in Germany) via Terraform module inputs without application changes.
