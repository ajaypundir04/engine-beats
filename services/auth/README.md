# Keycloak Auth Service

Identity & Access Management for EngineBeats using OIDC (OpenID Connect) with PKCE.

## Configuration as Code

The realm configuration is defined in [`realm-export.json`](./realm-export.json). It is automatically mounted and imported on startup in `docker-compose.yml`.

### Pre-configured Clients:
- `engine-beats-mobile`: Public client with PKCE for Flutter iOS/Android app.
- `engine-beats-web`: Public client for web checkout & portal.
- `engine-beats-api`: Bearer-only resource server validating JWT tokens issued by Keycloak.

### Pre-seeded Test Users:
- **Free User**: `demo@enginebeats.com` / `demo123`
- **Premium User**: `premium@enginebeats.com` / `premium123`

### Keycloak Endpoints (Dev):
- Realm Info: `http://localhost:8080/auth/realms/engine-beats`
- OIDC Discovery: `http://localhost:8080/auth/realms/engine-beats/.well-known/openid-configuration`
- Token Endpoint: `http://localhost:8080/auth/realms/engine-beats/protocol/openid-connect/token`
