package com.backend.gpms.features.lecturer.dto.request;

import com.backend.gpms.features.auth.domain.Role;
import jakarta.validation.constraints.*;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

@Getter
@Setter
@Builder
public class GiangVienCreateRequest {


    @Pattern(regexp = "^[0-9]{10}$", message = "MA_INVALID")
    private String maGiangVien;

    @NotEmpty(message = "HO_TEN_EMPTY")
    private String hoTen;

    @Email(regexp = "^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$", message = "EMAIL_INVALID")
    private String email;

    @Size(min = 6, message = "MAT_KHAU_INVALID")
    private String matKhau;

    @Pattern(
            regexp = "^(0?)(3[2-9]|5[25689]|7[0|6-9]|8[1-9]|9[0-9])[0-9]{7}$",
            message = "SO_DIEN_THOAI_INVALID"
    )
    private String soDienThoai;

    @Past(message = "NGAY_SINH_INVALID")
    private LocalDate ngaySinh;

    private String hocHam;

    private String hocVi;

    @NotNull(message = "BO_MON_EMPTY")
    private Long idBoMon;

    @NotNull(message = "VAI_TRO_EMPTY")
    private Role vaiTro;

    @NotNull(message = "QUOTA_INSTRUCT_EMPTY")
    private Integer quotaInstruct = 0;


}
