variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
}

variable "cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "Base VPC/VCN CIDR block"
}

variable "allowed_ingress_ports" {
  type        = list(number)
  default     = [80, 443]
  description = "Publicly accessible ports (default: HTTP and HTTPS only)"
}
