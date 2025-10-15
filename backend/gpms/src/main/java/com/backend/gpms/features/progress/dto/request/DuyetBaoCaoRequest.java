package com.backend.gpms.features.progress.dto.request;


import jakarta.validation.constraints.NotNull;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class DuyetBaoCaoRequest {
    @NotNull(message = "ID_BAO_CAO_REQUIRED")
    Long idBaoCao;
    String nhanXet;
    Double diemHuongDan;
}
