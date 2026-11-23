terraform {
  required_version = ">= 1.6.0"
}

module "network" {
  source                = "../../modules/network"
  environment           = "prod"
  allowed_ingress_ports = [80, 443]
}

# Production EU VPS (Hetzner Cloud Germany / OCI Paid Instance)
module "compute" {
  source         = "../../modules/compute"
  environment    = "prod"
  instance_shape = "cpx31" # 4 vCPU, 8 GB RAM in Falkenstein/Nuremberg
  ocpus          = 4
  memory_gb      = 8
  domain_name    = "api.enginebeats.com"
}

module "database" {
  source                = "../../modules/database"
  environment           = "prod"
  allocated_storage_gb  = 50
  backup_retention_days = 30
  enable_timescaledb    = true
}

module "storage" {
  source         = "../../modules/storage"
  environment    = "prod"
  retention_days = 90
}

module "dns_cdn" {
  source      = "../../modules/dns-cdn"
  environment = "prod"
  domain_name = "api.enginebeats.com"
}

module "billing" {
  source      = "../../modules/billing-config"
  environment = "prod"
}

module "secrets" {
  source      = "../../modules/secrets"
  environment = "prod"
}

module "observability" {
  source      = "../../modules/observability"
  environment = "prod"
  domain_name = "api.enginebeats.com"
}
