package com.backend.gpms.features.account.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class QuanTriVienResponse
{
    Long id;
    String hoTen;
    String email;
    String soDienThoai;
    String diaChi;
    Long idTaiKhoan;
    String vaiTro;
}
