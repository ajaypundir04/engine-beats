output "database_endpoint" {
  value = "postgres-${var.environment}.internal:5432"
}

output "database_name" {
  value = "enginebeats_${var.environment}"
}
