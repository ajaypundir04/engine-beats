package com.enginebeats.api.modules.billing;

import com.enginebeats.api.modules.billing.dto.EntitlementResponse;
import com.enginebeats.api.modules.billing.entity.UserEntitlementEntity;
import com.enginebeats.api.modules.billing.repository.UserEntitlementRepository;
import com.enginebeats.api.modules.billing.service.BillingService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Map;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class BillingServiceTest {

    @Mock
    private UserEntitlementRepository entitlementRepository;

    @InjectMocks
    private BillingService billingService;

    private final String userId = "user_driver_pro";

    @Test
    void isUserPremium_WhenActiveSubscription_ReturnsTrue() {
        UserEntitlementEntity entity = UserEntitlementEntity.builder()
                .userId(userId)
                .isPremium(true)
                .expiresAt(Instant.now().plus(30, ChronoUnit.DAYS))
                .build();

        when(entitlementRepository.findByUserId(userId)).thenReturn(Optional.of(entity));

        assertTrue(billingService.isUserPremium(userId));
    }

    @Test
    void isUserPremium_WhenExpired_ReturnsFalse() {
        UserEntitlementEntity entity = UserEntitlementEntity.builder()
                .userId(userId)
                .isPremium(true)
                .expiresAt(Instant.now().minus(2, ChronoUnit.DAYS))
                .build();

        when(entitlementRepository.findByUserId(userId)).thenReturn(Optional.of(entity));

        assertFalse(billingService.isUserPremium(userId));
    }

    @Test
    void processStripeWebhook_WhenCheckoutCompleted_GrantsEntitlement() {
        when(entitlementRepository.findByUserId(userId)).thenReturn(Optional.empty());

        Map<String, Object> event = Map.of(
                "type", "checkout.session.completed",
                "data", Map.of(
                        "object", Map.of(
                                "client_reference_id", userId,
                                "customer", "cus_12345",
                                "subscription", "sub_67890"
                        )
                )
        );

        billingService.processStripeWebhook(event);

        verify(entitlementRepository, times(1)).save(any(UserEntitlementEntity.class));
    }
}
