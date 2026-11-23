terraform {
  required_version = ">= 1.6.0"
}

# Generic Network Module (Compatible with Cloud Provider VPC / VCN)
resource "null_resource" "network_manifest" {
  triggers = {
    cidr_block   = var.cidr_block
    environment  = var.environment
    allowed_ports = join(",", var.allowed_ingress_ports)
  }
}
