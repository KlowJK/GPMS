package com.backend.gpms.features.account.dto.request;


import com.backend.gpms.features.auth.domain.User;
import com.backend.gpms.features.department.domain.BoMon;
import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import com.backend.gpms.features.auth.domain.Role;
import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
public class GiangVienAccountRequest {
    @NotBlank
    private String maGiangVien;

    @NotBlank
    private String hoTen;

    @Email
    @NotBlank
    private String email;

    @NotBlank
    private String matKhau;

    @NotBlank
    private String soDienThoai;

    @jakarta.validation.constraints.NotNull
    private Long idBoMon;

    @jakarta.validation.constraints.NotNull
    private Role vaiTro;

    private String hocHam;

    private String hocVi;

    @jakarta.validation.constraints.NotNull
    private Integer quotaInstruct = 0;

}
