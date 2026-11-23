# EngineBeats Backend API

Spring Boot 3.3.4 modular monolith backend for EngineBeats.

## Modules
- `vehicles`: Vehicle profile registration, OBD protocol configuration, and ownership verification.
- `telemetry`: High-throughput batched telemetry ingestion, deduplication by `batchId`, and time-series persistence.
- `trips`: Driving trips lifecycle (start/end), distance computation, speed averaging, and CSV export.
- `dtc`: Diagnostic Trouble Codes ingestion, SAE J2012 definitions lookup, and fault code clearance.
- `billing`: Three-channel subscription entitlements (Apple IAP / Google Play via RevenueCat, Web checkout via Stripe, backend entitlement verification).
- `common`: Spring Security OAuth2 resource server validating Keycloak JWT tokens, OpenAPI configuration, and global exception handlers.

## Running Tests
```bash
mvn clean test
```

## Running Locally
```bash
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```
Interactive Swagger UI: `http://localhost:8081/swagger-ui.html`
