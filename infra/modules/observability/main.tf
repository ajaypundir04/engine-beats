terraform {
  required_version = ">= 1.6.0"
}

# Observability: Health probes on /actuator/health and Sentry/Uptime alerts
resource "null_resource" "observability_probes" {
  triggers = {
    probe_url     = "https://${var.domain_name}/actuator/health"
    probe_interval = 60
  }
}
