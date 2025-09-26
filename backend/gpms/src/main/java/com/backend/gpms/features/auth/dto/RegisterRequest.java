package com.backend.gpms.features.auth.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import com.backend.gpms.features.auth.domain.Role;
import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
public class RegisterRequest {
    @Email @NotBlank
    private String email;
    @NotBlank
    private String matKhau;
    private String soDienThoai;
    private Role vaiTro = Role.SINH_VIEN;

}
