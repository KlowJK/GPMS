package com.backend.gpms.features.department.dto.response;

import com.backend.gpms.features.auth.domain.Role;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class TroLyKhoaResponse {
    Long id;
    String hoTen;
    String email;
    String soDienThoai;
    String diaChi;
    Long idTaiKhoan;
    String vaiTro;
}
