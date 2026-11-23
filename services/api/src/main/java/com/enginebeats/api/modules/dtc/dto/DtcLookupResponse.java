package com.enginebeats.api.modules.dtc.dto;

import com.enginebeats.api.modules.dtc.entity.DtcDefinitionEntity;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

public record DtcLookupResponse(
        String code,
        String system,
        String description,
        String severity,
        List<String> commonCauses
) {
    public static DtcLookupResponse fromEntity(DtcDefinitionEntity entity) {
        List<String> causes = (entity.getCommonCauses() != null && !entity.getCommonCauses().isBlank())
                ? Arrays.stream(entity.getCommonCauses().split(",")).map(String::trim).toList()
                : Collections.emptyList();

        return new DtcLookupResponse(
                entity.getCode(),
                entity.getSystem(),
                entity.getDescription(),
                entity.getSeverity(),
                causes
        );
    }
}
