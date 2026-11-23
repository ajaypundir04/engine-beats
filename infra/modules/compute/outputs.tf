output "instance_id" {
  value       = "inst-${var.environment}"
  description = "Compute instance ID"
}

output "user_data_rendered" {
  value     = local.cloud_init_content
  sensitive = true
}
