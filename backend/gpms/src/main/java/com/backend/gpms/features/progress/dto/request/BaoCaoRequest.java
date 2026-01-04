package com.backend.gpms.features.progress.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.*;
import lombok.experimental.FieldDefaults;
import org.springframework.web.multipart.MultipartFile;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class BaoCaoRequest {
    @NotNull(message = "DUONG_DAN_REQUIRED")
    MultipartFile duongDanFile;
}
