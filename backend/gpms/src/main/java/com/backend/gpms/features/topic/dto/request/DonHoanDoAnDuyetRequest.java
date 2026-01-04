package com.backend.gpms.features.topic.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.*;
import lombok.experimental.FieldDefaults;
import org.springframework.web.multipart.MultipartFile;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class DonHoanDoAnDuyetRequest {
    @NotNull(message = "DON_HOAN_DO_AN_ID_REQUIRED")
    Long donHoanDoAnId;

    MultipartFile bienbanHopPheDuyetFile;
}
