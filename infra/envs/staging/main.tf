terraform {
  required_version = ">= 1.6.0"
}

module "network" {
  source                = "../../modules/network"
  environment           = "staging"
  allowed_ingress_ports = [80, 443]
}

# Staging on Oracle Always Free Ampere A1 (2 OCPUs, 12 GB RAM)
module "compute" {
  source         = "../../modules/compute"
  environment    = "staging"
  instance_shape = "VM.Standard.A1.Flex"
  ocpus          = 2
  memory_gb      = 12
  domain_name    = "staging-api.enginebeats.com"
}

module "database" {
  source               = "../../modules/database"
  environment          = "staging"
  allocated_storage_gb = 10
  enable_timescaledb   = true
}

module "storage" {
  source         = "../../modules/storage"
  environment    = "staging"
  retention_days = 30
}

module "dns_cdn" {
  source      = "../../modules/dns-cdn"
  environment = "staging"
  domain_name = "staging-api.enginebeats.com"
}

module "observability" {
  source      = "../../modules/observability"
  environment = "staging"
  domain_name = "staging-api.enginebeats.com"
}
