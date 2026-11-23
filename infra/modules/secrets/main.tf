terraform {
  required_version = ">= 1.6.0"
}

# SOPS + Age encryption configuration
# Secret values are decrypted at deployment time and injected into container environments
resource "null_resource" "secrets_manifest" {
  triggers = {
    env = var.environment
  }
}
