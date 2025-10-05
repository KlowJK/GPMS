package com.backend.gpms.features.department.dto.request;

import jakarta.validation.constraints.NotEmpty;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class KhoaRequest {

    @NotEmpty(message = "KHOA_EMPTY")
    String tenKhoa;

}