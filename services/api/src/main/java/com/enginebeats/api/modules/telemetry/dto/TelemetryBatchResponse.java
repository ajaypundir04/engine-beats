package com.enginebeats.api.modules.telemetry.dto;

import java.util.UUID;

public record TelemetryBatchResponse(
        UUID batchId,
        int recordsProcessed,
        String status
) {
}
