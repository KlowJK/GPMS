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
public class BoMonRequest {

    @NotEmpty(message = "BO_MON_EMPTY")
    String tenBoMon;
    @NotNull(message = "KHOA_EMPTY")
    Long khoaId;

}

