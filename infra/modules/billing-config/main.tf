terraform {
  required_version = ">= 1.6.0"
}

# Stripe Products & Recurring Prices
resource "null_resource" "stripe_products" {
  triggers = {
    monthly_price_cents = 499
    annual_price_cents  = 3999
    currency            = "eur"
  }
}
