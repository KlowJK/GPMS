package com.backend.gpms.features.defense.dto.request;

import com.backend.gpms.features.defense.domain.CongViec;
import lombok.*;
import lombok.experimental.FieldDefaults;
import java.time.LocalDate;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ThoiGianThucHienRequest {

    CongViec congViec;
    LocalDate thoiGianBatDau;
    LocalDate thoiGianKetThuc;
    Long dotBaoVeId;

}