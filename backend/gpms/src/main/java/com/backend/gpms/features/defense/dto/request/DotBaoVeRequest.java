package com.backend.gpms.features.defense.dto.request;

import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDate;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class DotBaoVeRequest {

    String tenDotBaoVe;
    int hocKi;
    LocalDate thoiGianBatDau;
    LocalDate thoiGianKetThuc;
    String namHoc;

}
