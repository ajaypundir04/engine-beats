output "network_id" {
  value       = "net-${var.environment}"
  description = "Network identifier"
}

output "public_subnet_id" {
  value       = "subnet-pub-${var.environment}"
  description = "Public subnet ID"
}

output "allowed_ports" {
  value = var.allowed_ingress_ports
}
