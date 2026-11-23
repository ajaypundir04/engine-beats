terraform {
  required_version = ">= 1.6.0"
}

# Cloudflare DNS, Edge Caching, and WAF rate-limiting
resource "null_resource" "dns_cdn_manifest" {
  triggers = {
    domain = var.domain_name
    ssl    = "full_strict"
    waf    = "enabled"
  }
}
