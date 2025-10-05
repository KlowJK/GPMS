package com.backend.gpms.features.council.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDate;
import java.util.List;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class HoiDongRequest {
    @NotBlank(message = "TEN_HOI_DONG_REQUIRED")
    String tenHoiDong;

    @NotNull(message = "THOI_GIAN_BAT_DAU_REQUIRED")
    LocalDate thoiGianBatDau;

    @NotNull(message = "THOI_GIAN_KET_THUC_REQUIRED")
    LocalDate thoiGianKetThuc;

    @NotNull(message = "DOT_BAO_VE_ID_REQUIRED")
    Long dotBaoVeId;

    List<LecturerItem> lecturers;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class LecturerItem {
        @NotNull(message = "GIANG_VIEN_ID_REQUIRED")
        Long giangVienId;
    }
}
