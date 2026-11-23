package com.enginebeats.api.modules.billing.service;

import com.enginebeats.api.modules.billing.dto.CheckoutSessionResponse;
import com.enginebeats.api.modules.billing.dto.EntitlementResponse;
import com.enginebeats.api.modules.billing.entity.UserEntitlementEntity;
import com.enginebeats.api.modules.billing.repository.UserEntitlementRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class BillingService {

    private final UserEntitlementRepository entitlementRepository;

    @Value("${stripe.api-key:sk_test_mock}")
    private String stripeApiKey;

    @Transactional(readOnly = true)
    public boolean isUserPremium(String userId) {
        return entitlementRepository.findByUserId(userId)
                .map(e -> e.isPremium() && (e.getExpiresAt() == null || e.getExpiresAt().isAfter(Instant.now())))
                .orElse(false);
    }

    @Transactional(readOnly = true)
    public EntitlementResponse getEntitlements(String userId) {
        Optional<UserEntitlementEntity> optional = entitlementRepository.findByUserId(userId);
        if (optional.isPresent()) {
            UserEntitlementEntity entity = optional.get();
            boolean active = entity.isPremium() && (entity.getExpiresAt() == null || entity.getExpiresAt().isAfter(Instant.now()));
            return new EntitlementResponse(
                    userId,
                    active,
                    entity.getPlan(),
                    entity.getExpiresAt(),
                    active ? EntitlementResponse.PREMIUM_FEATURES : EntitlementResponse.FREE_FEATURES
            );
        }
        return new EntitlementResponse(
                userId,
                false,
                "FREE",
                null,
                EntitlementResponse.FREE_FEATURES
        );
    }

    @Transactional
    public void grantOrUpdateEntitlement(String userId, boolean isPremium, String plan,
                                         Instant expiresAt, String source,
                                         String customerId, String subscriptionId) {
        UserEntitlementEntity entity = entitlementRepository.findByUserId(userId)
                .orElseGet(() -> UserEntitlementEntity.builder()
                        .userId(userId)
                        .build());

        entity.setPremium(isPremium);
        entity.setPlan(plan);
        entity.setExpiresAt(expiresAt);
        entity.setSource(source);
        if (customerId != null) entity.setStripeCustomerId(customerId);
        if (subscriptionId != null) entity.setStripeSubscriptionId(subscriptionId);
        entity.setUpdatedAt(Instant.now());

        entitlementRepository.save(entity);
        log.info("Updated entitlement for user {}: premium={}, plan={}, expiresAt={}", userId, isPremium, plan, expiresAt);
    }

    public CheckoutSessionResponse createCheckoutSession(String userId, String priceId, String successUrl, String cancelUrl) {
        // Generates checkout session (mock / production Stripe)
        String mockSessionId = "cs_test_" + UUID.randomUUID();
        String checkoutUrl = (successUrl != null && !successUrl.isBlank())
                ? successUrl + "?session_id=" + mockSessionId
                : "https://checkout.stripe.com/pay/" + mockSessionId;

        log.info("Created checkout session {} for user {}", mockSessionId, userId);
        return new CheckoutSessionResponse(mockSessionId, checkoutUrl);
    }

    @Transactional
    public void processStripeWebhook(Map<String, Object> event) {
        String eventType = (String) event.get("type");
        log.info("Processing Stripe webhook event: {}", eventType);

        if ("checkout.session.completed".equals(eventType)) {
            Map<?, ?> data = (Map<?, ?>) event.get("data");
            if (data != null && data.get("object") instanceof Map<?, ?> obj) {
                String clientReferenceId = (String) obj.get("client_reference_id");
                String customerId = (String) obj.get("customer");
                String subscriptionId = (String) obj.get("subscription");

                if (clientReferenceId != null) {
                    grantOrUpdateEntitlement(
                            clientReferenceId,
                            true,
                            "PRO_ANNUAL",
                            Instant.now().plus(365, ChronoUnit.DAYS),
                            "STRIPE",
                            customerId,
                            subscriptionId
                    );
                }
            }
        } else if ("customer.subscription.deleted".equals(eventType)) {
            Map<?, ?> data = (Map<?, ?>) event.get("data");
            if (data != null && data.get("object") instanceof Map<?, ?> obj) {
                String subId = (String) obj.get("id");
                entitlementRepository.findByStripeSubscriptionId(subId).ifPresent(entity -> {
                    entity.setPremium(false);
                    entity.setExpiresAt(Instant.now());
                    entitlementRepository.save(entity);
                    log.info("Subscription canceled for user: {}", entity.getUserId());
                });
            }
        }
    }

    @Transactional
    public void processRevenueCatWebhook(Map<String, Object> event) {
        log.info("Processing RevenueCat webhook event");
        if (event.get("event") instanceof Map<?, ?> eventData) {
            String appUserId = (String) eventData.get("app_user_id");
            String type = (String) eventData.get("type");

            if (appUserId != null) {
                boolean isPro = "INITIAL_PURCHASE".equals(type) || "RENEWAL".equals(type);
                grantOrUpdateEntitlement(
                        appUserId,
                        isPro,
                        "PRO_STORE",
                        isPro ? Instant.now().plus(30, ChronoUnit.DAYS) : Instant.now(),
                        "REVENUECAT",
                        null,
                        null
                );
            }
        }
    }
}
