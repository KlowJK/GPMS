package com.backend.gpms.features.account.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Setter
@Getter

public class SinhVienAccountRequest {
    @NotBlank
    private String maSinhVien;

    @NotBlank
    private String hoTen;

    @Email
    @NotBlank
    private String email;

    @NotBlank
    private String matKhau;

    @NotBlank
    private String soDienThoai;

    @NotNull
    private Long idLop; // combobox "Chọn lớp"

    @NotNull
    private Boolean duDieuKien; // "Đủ điều kiện" / "Chưa đủ"
}