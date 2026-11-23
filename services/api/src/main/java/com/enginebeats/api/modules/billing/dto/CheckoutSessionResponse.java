package com.enginebeats.api.modules.billing.dto;

public record CheckoutSessionResponse(
        String sessionId,
        String checkoutUrl
) {
}
