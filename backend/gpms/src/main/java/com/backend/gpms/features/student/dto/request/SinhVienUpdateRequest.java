package com.backend.gpms.features.student.dto.request;

import lombok.*;

import jakarta.validation.constraints.Email;
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
public class SinhVienUpdateRequest {

    @NotEmpty(message = "HO_TEN_EMPTY")
    String hoTen;

    @Pattern(
            regexp = "^(0?)(3[2-9]|5[25689]|7[0|6-9]|8[1-9]|9[0-9])[0-9]{7}$",
            message = "SO_DIEN_THOAI_INVALID"
    )
    String soDienThoai;

    @Email(message = "EMAIL_INVALID", regexp = "^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$")
    String email;

    String matKhau;

    @NotNull(message = "LOP_EMPTY")
    Long lopId;

}

