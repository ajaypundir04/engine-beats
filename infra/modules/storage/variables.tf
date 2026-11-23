variable "environment" {
  type = string
}

variable "retention_days" {
  type        = number
  default     = 90
  description = "Days after which raw telemetry exports are automatically purged"
}
