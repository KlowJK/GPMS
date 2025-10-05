package com.backend.gpms.features.department.dto.request;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class NganhRequest {

    @NotEmpty(message = "NGANH_EMPTY")
    String tenNganh;
    @NotNull(message = "KHOA_EMPTY")
    Long khoaId;

}
