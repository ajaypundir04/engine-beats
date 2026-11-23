terraform {
  required_version = ">= 1.6.0"
}

# Object storage bucket for trip CSV exports and database backups
resource "null_resource" "storage_bucket" {
  triggers = {
    bucket_name   = "enginebeats-${var.environment}-storage"
    lifecycle_days = var.retention_days
  }
}
