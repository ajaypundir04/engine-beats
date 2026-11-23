terraform {
  required_version = ">= 1.6.0"
}

locals {
  cloud_init_content = templatefile("${path.module}/templates/cloud-init.yaml", {
    environment = var.environment
    domain_name = var.domain_name
  })
}

resource "null_resource" "compute_manifest" {
  triggers = {
    instance_shape = var.instance_shape
    ocpus          = var.ocpus
    memory_gb      = var.memory_gb
    environment    = var.environment
  }
}
