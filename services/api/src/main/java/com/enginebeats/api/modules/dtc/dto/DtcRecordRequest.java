package com.enginebeats.api.modules.dtc.dto;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;

import java.util.List;
import java.util.UUID;

public record DtcRecordRequest(
        @NotNull UUID vehicleId,
        @NotNull @NotEmpty List<String> codes,
        Boolean milStatus
) {
}
