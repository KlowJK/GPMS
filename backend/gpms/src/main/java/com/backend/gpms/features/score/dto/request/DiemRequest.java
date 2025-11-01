package com.backend.gpms.features.score.dto.request;


import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DiemRequest {
    @NotNull(message = "DE_TAI_ID_REQUIRED")
    private Long idDeTai;

    @NotNull(message = "DIEM_REQUIRED")
    @DecimalMin(value = "0.0", message = "DIEM_MIN_0")
    @DecimalMax(value = "10.0", message = "DIEM_MAX_10")
    private Double diem;

    private String nhanXet;
}
