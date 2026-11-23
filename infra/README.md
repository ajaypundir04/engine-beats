# EngineBeats Infrastructure as Code (OpenTofu / Terraform)

Modular cloud infrastructure for EngineBeats supporting free-tier staging and production deployments.

## Architecture

```
Internet ──► Cloudflare (WAF, DDoS, TLS, Edge Caching)
                  │
                  ▼
              Compute Host (Oracle Always Free Ampere A1 or Hetzner VPS)
              ├── Caddy Reverse Proxy (Port 80/443)
              ├── Spring Boot API (:8081)
              └── Keycloak OIDC (:8080)
                  │
                  ▼
          PostgreSQL 16 (+TimescaleDB) ──► Object Storage (Cloudflare R2 / OCI)
                                           (Nightly Backups & Trip Exports)
```

## Directory Structure

```
infra/
├── modules/
│   ├── network/            # VCN/VPC, private/public subnets, security lists (only 80/443 public)
│   ├── compute/            # VM instance, ARM64 shape, cloud-init automated bootstrap
│   ├── database/           # PostgreSQL configuration, backup schedules
│   ├── storage/            # Object storage buckets, 90-day telemetry retention lifecycle
│   ├── dns-cdn/            # Cloudflare DNS, WAF rules, and rate limits
│   ├── billing-config/     # Stripe products and recurring prices as code
│   ├── secrets/            # SOPS + age encryption configuration
│   └── observability/      # Health check probes & alerts
└── envs/
    ├── dev/                # Local testing / dev environment
    ├── staging/            # Oracle Always Free / Aiven free tier setup
    └── prod/               # Production EU VPS (Hetzner Germany / OCI) with backups
```

## Usage

### 1. Staging Deployment (Free Tier)
```bash
cd infra/envs/staging
cp terraform.tfvars.example terraform.tfvars
tofu init
tofu plan
tofu apply
```

### 2. Production Deployment
```bash
cd infra/envs/prod
cp terraform.tfvars.example terraform.tfvars
tofu init
tofu apply
```
Swapping between staging and production is purely a module input configuration (e.g. provider credentials and instance shape), keeping application code identical across environments.
