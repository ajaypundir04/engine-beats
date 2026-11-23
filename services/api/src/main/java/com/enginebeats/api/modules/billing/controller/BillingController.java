package com.enginebeats.api.modules.billing.controller;

import com.enginebeats.api.common.security.SecurityUtils;
import com.enginebeats.api.modules.billing.dto.CheckoutSessionResponse;
import com.enginebeats.api.modules.billing.dto.EntitlementResponse;
import com.enginebeats.api.modules.billing.service.BillingService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/billing")
@RequiredArgsConstructor
@Tag(name = "Billing", description = "Subscriptions, In-App Purchases, and Feature Entitlements")
public class BillingController {

    private final BillingService billingService;

    @GetMapping("/entitlements")
    @Operation(summary = "Get feature entitlements for current user")
    public ResponseEntity<EntitlementResponse> getEntitlements() {
        String userId = SecurityUtils.getCurrentUserId();
        return ResponseEntity.ok(billingService.getEntitlements(userId));
    }

    @PostMapping("/checkout-session")
    @Operation(summary = "Create Stripe Checkout session for web billing")
    public ResponseEntity<CheckoutSessionResponse> createCheckoutSession(@RequestBody Map<String, String> body) {
        String userId = SecurityUtils.getCurrentUserId();
        String priceId = body.getOrDefault("priceId", "price_pro_monthly");
        String successUrl = body.get("successUrl");
        String cancelUrl = body.get("cancelUrl");
        return ResponseEntity.ok(billingService.createCheckoutSession(userId, priceId, successUrl, cancelUrl));
    }

    @PostMapping("/webhooks/stripe")
    @Operation(summary = "Stripe webhook endpoint for subscription events")
    public ResponseEntity<Void> stripeWebhook(@RequestBody Map<String, Object> payload) {
        billingService.processStripeWebhook(payload);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/webhooks/revenuecat")
    @Operation(summary = "RevenueCat webhook endpoint for Apple/Google Play store receipts")
    public ResponseEntity<Void> revenueCatWebhook(@RequestBody Map<String, Object> payload) {
        billingService.processRevenueCatWebhook(payload);
        return ResponseEntity.ok().build();
    }
}
