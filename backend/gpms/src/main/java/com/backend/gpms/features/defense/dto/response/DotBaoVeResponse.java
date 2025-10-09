package com.backend.gpms.features.defense.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDate;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
@JsonInclude(JsonInclude.Include.NON_EMPTY)
public class DotBaoVeResponse {
    Long id;//
    String tenDotBaoVe;//
    String hocKi;//
    LocalDate thoiGianBatDau;//
    LocalDate thoiGianKetThuc;//
    String namHoc;

}
