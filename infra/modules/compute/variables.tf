variable "environment" {
  type        = string
  description = "Environment name"
}

variable "instance_shape" {
  type        = string
  default     = "VM.Standard.A1.Flex"
  description = "Compute instance shape (e.g. Oracle Always Free Ampere A1 or Hetzner CPX21)"
}

variable "ocpus" {
  type        = number
  default     = 2
  description = "Number of OCPUs / vCPUs"
}

variable "memory_gb" {
  type        = number
  default     = 12
  description = "Memory in GB (e.g. 12 GB for Oracle Always Free ARM64)"
}

variable "domain_name" {
  type        = string
  default     = "api.enginebeats.com"
  description = "Domain name for Caddy automatic TLS"
}
