package com.enginebeats.api.modules.vehicles;

import com.enginebeats.api.modules.billing.service.BillingService;
import com.enginebeats.api.modules.vehicles.dto.CreateVehicleRequest;
import com.enginebeats.api.modules.vehicles.dto.VehicleResponse;
import com.enginebeats.api.modules.vehicles.entity.VehicleEntity;
import com.enginebeats.api.modules.vehicles.repository.VehicleRepository;
import com.enginebeats.api.modules.vehicles.service.VehicleService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class VehicleServiceTest {

    @Mock
    private VehicleRepository vehicleRepository;

    @Mock
    private BillingService billingService;

    @InjectMocks
    private VehicleService vehicleService;

    private final String userId = "user_test_123";

    @Test
    void createVehicle_WhenFirstVehicle_ShouldSucceed() {
        when(vehicleRepository.findByUserIdOrderByCreatedAtDesc(userId)).thenReturn(List.of());

        VehicleEntity savedEntity = VehicleEntity.builder()
                .id(UUID.randomUUID())
                .userId(userId)
                .vin("1HGCR2F83HA123456")
                .make("Honda")
                .model("Accord")
                .year(2017)
                .protocol("ISO 15765-4 (CAN 11/500)")
                .createdAt(Instant.now())
                .build();

        when(vehicleRepository.save(any(VehicleEntity.class))).thenReturn(savedEntity);

        CreateVehicleRequest request = new CreateVehicleRequest(
                "1HGCR2F83HA123456", "Honda", "Accord", 2017, "Daily", null
        );

        VehicleResponse response = vehicleService.createVehicle(request, userId);

        assertNotNull(response);
        assertEquals("Honda", response.make());
        assertEquals("1HGCR2F83HA123456", response.vin());
        verify(vehicleRepository, times(1)).save(any(VehicleEntity.class));
    }

    @Test
    void createVehicle_WhenSecondVehicleAndNotPremium_ShouldThrowException() {
        VehicleEntity firstVehicle = VehicleEntity.builder()
                .id(UUID.randomUUID())
                .userId(userId)
                .build();

        when(vehicleRepository.findByUserIdOrderByCreatedAtDesc(userId)).thenReturn(List.of(firstVehicle));
        when(billingService.isUserPremium(userId)).thenReturn(false);

        CreateVehicleRequest request = new CreateVehicleRequest(
                "1HGCR2F83HA999999", "Toyota", "Camry", 2020, "Second Car", null
        );

        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () ->
                vehicleService.createVehicle(request, userId));

        assertTrue(ex.getMessage().contains("Free tier allows only 1 registered vehicle"));
        verify(vehicleRepository, never()).save(any(VehicleEntity.class));
    }
}
