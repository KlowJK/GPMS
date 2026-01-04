package com.backend.gpms.features.department.dto.request;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
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

    @NotNull(message = "MA_NGANH_EMPTY")
    @Pattern(regexp = "^TLA.*", message = "MA_NGANH_INVALID_PREFIX")
    String maNganh;

    @NotNull(message = "KHOA_EMPTY")
    Long khoaId;


}
