package com.enginebeats.api.modules.vehicles.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CreateVehicleRequest(
        @NotBlank @Size(min = 11, max = 17) String vin,
        @NotBlank String make,
        @NotBlank String model,
        @NotNull Integer year,
        String nickname,
        String protocol
) {
}
