package com.backend.gpms.features.student.dto.request;

import jakarta.validation.constraints.*;
import lombok.*;
import java.time.LocalDate;

@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SinhVienCreateRequest {

    @NotBlank(message = "Họ tên không được để trống")
    private String hoTen;

    @NotBlank(message = "Mã sinh viên không được để trống")
    @Size(max = 32, message = "Mã sinh viên tối đa 32 ký tự")
    private String maSinhVien;

    @Pattern(regexp = "^(\\+?\\d{7,15})?$", message = "Số điện thoại không hợp lệ")
    private String soDienThoai;

    // Nếu là URL công khai:
    @Size(max = 512)
    private String duongDanAnhDaiDien;

    @Size(max = 512)
    private String duongDanCV;

    @Past(message = "Ngày sinh phải trong quá khứ")
    private LocalDate ngaySinh;

    @Size(max = 255)
    private String diaChi;

    @NotNull(message = "nganhId là bắt buộc")
    private Long nganhId;

    @NotNull(message = "lopId là bắt buộc")
    private Long lopId;

    // Liên kết tới tài khoản đăng nhập
    @NotNull(message = "userId là bắt buộc")
    private Long userId;

    // Trạng thái kích hoạt hồ sơ SV (khác với kích hoạt tài khoản hệ thống)
    private Boolean kichHoat;
}
