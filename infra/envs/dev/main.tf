terraform {
  required_version = ">= 1.6.0"
}

module "network" {
  source      = "../../modules/network"
  environment = "dev"
}

module "compute" {
  source         = "../../modules/compute"
  environment    = "dev"
  instance_shape = "local.docker"
  domain_name    = "localhost"
}

module "database" {
  source      = "../../modules/database"
  environment = "dev"
}

module "storage" {
  source      = "../../modules/storage"
  environment = "dev"
}

module "billing" {
  source      = "../../modules/billing-config"
  environment = "dev"
}
