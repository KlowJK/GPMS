package com.backend.gpms.features.defense.dto.response;

import java.time.LocalDate;

import com.backend.gpms.features.defense.domain.CongViec;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
@JsonInclude(JsonInclude.Include.NON_EMPTY)
public class ThoiGianThucHienResponse {

    Long id;
    CongViec congViec;
    LocalDate thoiGianBatDau;
    LocalDate thoiGianKetThuc;
    String tenDotBaoVe;

}