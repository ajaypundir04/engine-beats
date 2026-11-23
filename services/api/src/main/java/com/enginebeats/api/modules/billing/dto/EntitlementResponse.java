package com.enginebeats.api.modules.billing.dto;

import java.time.Instant;
import java.util.List;

public record EntitlementResponse(
        String userId,
        boolean isPremium,
        String plan,
        Instant expiresAt,
        List<String> features
) {
    public static final List<String> PREMIUM_FEATURES = List.of(
            "TRIP_HISTORY_SYNC",
            "DTC_DEEP_ANALYSIS",
            "CSV_EXPORT",
            "MULTI_VEHICLE"
    );

    public static final List<String> FREE_FEATURES = List.of(
            "LIVE_DASHBOARD",
            "BASIC_DTC_READ",
            "SINGLE_VEHICLE"
    );
}
