package com.backend.gpms.features.student.dto.request;

import jakarta.validation.constraints.*;
import lombok.*;
import java.time.LocalDate;

@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SinhVienCreateRequest {

    @Pattern(regexp = "^[0-9]{10}$", message = "MA_INVALID")
    private String maSinhVien;

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

    @Size(max = 255, message = "DIA_CHI_INVALID")
    private String diaChi;

    @NotNull(message = "LOP_EMPTY")
    private Long idLop;
}
