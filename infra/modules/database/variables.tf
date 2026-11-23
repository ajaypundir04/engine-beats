variable "environment" {
  type = string
}

variable "allocated_storage_gb" {
  type    = number
  default = 20
}

variable "backup_retention_days" {
  type    = number
  default = 14
}

variable "enable_timescaledb" {
  type    = bool
  default = true
}
