terraform {
  required_version = ">= 1.6.0"
}

resource "null_resource" "database_config" {
  triggers = {
    environment     = var.environment
    allocated_gb    = var.allocated_storage_gb
    backup_retention = var.backup_retention_days
    timescaledb     = var.enable_timescaledb
  }
}
