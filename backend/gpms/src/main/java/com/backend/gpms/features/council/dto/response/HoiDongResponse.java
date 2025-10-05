package com.backend.gpms.features.council.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;
import java.time.LocalDate;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class HoiDongResponse {
    Long id;
    String tenHoiDong;
    LocalDate thoiGianBatDau;
    LocalDate thoiGianKetThuc;
}