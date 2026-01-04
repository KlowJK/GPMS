package com.backend.gpms.features.council.dto.request;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDate;
import java.util.List;

@Setter
@Getter
@Data @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class PhanCongPhanBienRequest {
    @NotBlank(message = "DE_TAI_ID_REQUIRED")
    String idDeTai;

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
