package com.enginebeats.api.modules.dtc.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.*;

@Entity
@Table(name = "dtc_definitions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DtcDefinitionEntity {

    @Id
    @Column(length = 10)
    private String code;

    @Column(nullable = false, length = 100)
    private String system;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String description;

    @Column(nullable = false, length = 20)
    private String severity;

    @Column(name = "common_causes", columnDefinition = "TEXT")
    private String commonCauses;
}
