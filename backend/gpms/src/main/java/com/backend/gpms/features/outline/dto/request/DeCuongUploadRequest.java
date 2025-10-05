package com.backend.gpms.features.outline.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class DeCuongUploadRequest {
    @NotBlank(message = "FILE_URL_EMPTY")
    @Pattern(
            regexp = "^(https?://.+)$",
            message = "FILE_URL_INVALID"
    )
    String fileUrl;
}