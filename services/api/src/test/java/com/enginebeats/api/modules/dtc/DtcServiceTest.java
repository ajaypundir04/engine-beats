package com.enginebeats.api.modules.dtc;

import com.enginebeats.api.modules.dtc.dto.DtcLookupResponse;
import com.enginebeats.api.modules.dtc.dto.DtcRecordRequest;
import com.enginebeats.api.modules.dtc.dto.DtcRecordResponse;
import com.enginebeats.api.modules.dtc.entity.DtcDefinitionEntity;
import com.enginebeats.api.modules.dtc.entity.DtcRecordEntity;
import com.enginebeats.api.modules.dtc.repository.DtcDefinitionRepository;
import com.enginebeats.api.modules.dtc.repository.DtcRecordRepository;
import com.enginebeats.api.modules.dtc.service.DtcService;
import com.enginebeats.api.modules.vehicles.entity.VehicleEntity;
import com.enginebeats.api.modules.vehicles.repository.VehicleRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class DtcServiceTest {

    @Mock
    private DtcRecordRepository recordRepository;

    @Mock
    private DtcDefinitionRepository definitionRepository;

    @Mock
    private VehicleRepository vehicleRepository;

    @InjectMocks
    private DtcService dtcService;

    private final String userId = "user_driver_1";
    private final UUID vehicleId = UUID.randomUUID();

    @Test
    void lookupDefinition_WhenCodeExists_ReturnsDefinition() {
        DtcDefinitionEntity def = DtcDefinitionEntity.builder()
                .code("P0300")
                .system("Powertrain / Ignition")
                .description("Random/Multiple Cylinder Misfire Detected")
                .severity("CRITICAL")
                .commonCauses("Spark plugs, coil packs")
                .build();

        when(definitionRepository.findByCodeIgnoreCase("P0300")).thenReturn(Optional.of(def));

        DtcLookupResponse response = dtcService.lookupDefinition("P0300");

        assertNotNull(response);
        assertEquals("P0300", response.code());
        assertEquals("CRITICAL", response.severity());
        assertEquals(2, response.commonCauses().size());
    }

    @Test
    void recordDtcs_ShouldLookUpDefinitionsAndSaveRecords() {
        when(vehicleRepository.findByIdAndUserId(vehicleId, userId)).thenReturn(Optional.of(
                VehicleEntity.builder().id(vehicleId).userId(userId).build()
        ));

        DtcDefinitionEntity def = DtcDefinitionEntity.builder()
                .code("P0171")
                .description("System Too Lean (Bank 1)")
                .severity("MEDIUM")
                .build();
        when(definitionRepository.findByCodeIgnoreCase("P0171")).thenReturn(Optional.of(def));

        when(recordRepository.saveAll(anyList())).thenAnswer(invocation -> invocation.getArgument(0));

        DtcRecordRequest request = new DtcRecordRequest(vehicleId, List.of("P0171"), true);
        List<DtcRecordResponse> responses = dtcService.recordDtcs(request, userId);

        assertEquals(1, responses.size());
        assertEquals("P0171", responses.get(0).code());
        assertEquals("MEDIUM", responses.get(0).severity());
        verify(recordRepository, times(1)).saveAll(anyList());
    }
}
