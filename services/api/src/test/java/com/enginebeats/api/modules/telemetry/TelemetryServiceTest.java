package com.enginebeats.api.modules.telemetry;

import com.enginebeats.api.modules.telemetry.dto.TelemetryBatchRequest;
import com.enginebeats.api.modules.telemetry.dto.TelemetryBatchResponse;
import com.enginebeats.api.modules.telemetry.dto.TelemetryReadingDto;
import com.enginebeats.api.modules.telemetry.entity.TelemetryBatchEntity;
import com.enginebeats.api.modules.telemetry.repository.TelemetryBatchRepository;
import com.enginebeats.api.modules.telemetry.repository.TelemetryReadingRepository;
import com.enginebeats.api.modules.telemetry.service.TelemetryService;
import com.enginebeats.api.modules.vehicles.entity.VehicleEntity;
import com.enginebeats.api.modules.vehicles.repository.VehicleRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class TelemetryServiceTest {

    @Mock
    private TelemetryBatchRepository batchRepository;

    @Mock
    private TelemetryReadingRepository readingRepository;

    @Mock
    private VehicleRepository vehicleRepository;

    @InjectMocks
    private TelemetryService telemetryService;

    private final String userId = "user_driver_1";
    private final UUID vehicleId = UUID.randomUUID();
    private final UUID batchId = UUID.randomUUID();

    @Test
    void processBatch_WhenNewBatch_ShouldProcessAndPersistReadings() {
        when(batchRepository.existsById(batchId)).thenReturn(false);
        when(vehicleRepository.findByIdAndUserId(vehicleId, userId)).thenReturn(Optional.of(
                VehicleEntity.builder().id(vehicleId).userId(userId).build()
        ));

        TelemetryReadingDto reading = new TelemetryReadingDto(
                Instant.now(), 2450.0, 72.5, 90, 32.0, 65.0, 14.5, 13.8, 22, 25.0
        );
        TelemetryBatchRequest request = new TelemetryBatchRequest(batchId, vehicleId, null, List.of(reading));

        TelemetryBatchResponse response = telemetryService.processBatch(request, userId);

        assertNotNull(response);
        assertEquals(batchId, response.batchId());
        assertEquals(1, response.recordsProcessed());
        assertEquals("PROCESSED", response.status());

        verify(batchRepository, times(1)).save(any(TelemetryBatchEntity.class));
        verify(readingRepository, times(1)).saveAll(anyList());
    }

    @Test
    void processBatch_WhenDuplicateBatch_ShouldBeIdempotent() {
        when(batchRepository.existsById(batchId)).thenReturn(true);

        TelemetryReadingDto reading = new TelemetryReadingDto(Instant.now(), 2000.0, 60.0, 85, 20.0, 50.0, 10.0, 13.5, 20, 20.0);
        TelemetryBatchRequest request = new TelemetryBatchRequest(batchId, vehicleId, null, List.of(reading));

        TelemetryBatchResponse response = telemetryService.processBatch(request, userId);

        assertNotNull(response);
        assertEquals(batchId, response.batchId());
        assertEquals("ALREADY_PROCESSED", response.status());

        // Should not insert duplicate records
        verify(batchRepository, never()).save(any());
        verify(readingRepository, never()).saveAll(any());
    }
}
