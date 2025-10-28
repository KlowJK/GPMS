package com.backend.gpms.features.department.dto.request;

import com.backend.gpms.features.auth.domain.Role;
import jakarta.validation.constraints.*;
import lombok.*;
import lombok.experimental.FieldDefaults;


@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class TroLyKhoaRequest {

    @NotEmpty(message = "HO_TEN_EMPTY")
    String hoTen;

    @Email(regexp = "^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$", message = "EMAIL_INVALID")
    String email;

    @Size(min = 6, message = "MAT_KHAU_INVALID")
    String matKhau;

    @Pattern(
            regexp = "^(0?)(3[2-9]|5[25689]|7[0|6-9]|8[1-9]|9[0-9])[0-9]{7}$",
            message = "SO_DIEN_THOAI_INVALID"
    )

    String soDienThoai;

    String diaChi;
}
