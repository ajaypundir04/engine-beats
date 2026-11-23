# EngineBeats API Contracts

This directory hosts the OpenAPI 3.0 specification for the EngineBeats platform.

## Usage

- **Specification**: [`openapi.yaml`](./openapi.yaml)
- **Dart Client Generation**:
  ```bash
  openapi-generator-cli generate -i openapi.yaml -g dart-dio -o ../apps/mobile/lib/core/network/generated
  ```
- **Java Client / Server Stubs Generation**:
  ```bash
  openapi-generator-cli generate -i openapi.yaml -g spring -o ../services/api/generated
  ```
- **Live Documentation**:
  When running the API (`services/api`), interactive Swagger UI is available at:
  `http://localhost:8081/swagger-ui.html`
