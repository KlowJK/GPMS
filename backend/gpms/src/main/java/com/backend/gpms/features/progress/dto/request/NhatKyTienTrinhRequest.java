package com.backend.gpms.features.progress.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.*;
import lombok.experimental.FieldDefaults;
import org.springframework.web.multipart.MultipartFile;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
public class NhatKyTienTrinhRequest {
    @NotNull(message = "NHAT_KY_ID_REQUIRED")
    Long idNhatKy;
    @NotNull(message = "NOI_DUNG_REQUIRED")
    String noiDung;
    MultipartFile duongDanFile;
}
