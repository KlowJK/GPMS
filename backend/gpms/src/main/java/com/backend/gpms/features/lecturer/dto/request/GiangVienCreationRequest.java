package com.backend.gpms.features.lecturer.dto.request;

import com.fasterxml.jackson.annotation.JsonInclude;
import jakarta.validation.constraints.*;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class GiangVienCreationRequest {

    @Pattern(regexp = "^[0-9]{10}$", message = "MA_SV_INVALID")
    String maGiangVien;

    @NotEmpty(message = "HO_TEN_EMPTY")
    String hoTen;

    @Pattern(
            regexp = "^(0?)(3[2-9]|5[25689]|7[0|6-9]|8[1-9]|9[0-9])[0-9]{7}$",
            message = "SO_DIEN_THOAI_INVALID"
    )
    String soDienThoai;
    String hocVi;
    String hocHam;
    @Email(message = "EMAIL_INVALID", regexp = "^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$")
    String email;
    @Size(min = 6, message = "PASSWORD_INVALID")
    String matKhau;
    @NotNull(message = "BO_MON_EMPTY")
    Long idBoMon;

}