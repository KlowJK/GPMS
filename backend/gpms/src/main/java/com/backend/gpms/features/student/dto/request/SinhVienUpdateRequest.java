package com.backend.gpms.features.student.dto.request;

import jakarta.validation.constraints.*;
import lombok.*;
import java.time.LocalDate;

@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SinhVienUpdateRequest {

    // Cho phép null = không đổi
    private String hoTen;

    @Size(max = 32)
    private String maSinhVien;

    @Pattern(regexp = "^(\\+?\\d{7,15})?$", message = "Số điện thoại không hợp lệ")
    private String soDienThoai;

    @Size(max = 512)
    private String duongDanAnhDaiDien;

    @Size(max = 512)
    private String duongDanCV;

    @Past(message = "Ngày sinh phải trong quá khứ")
    private LocalDate ngaySinh;

    @Size(max = 255)
    private String diaChi;

    private Long nganhId;
    private Long lopId;

    private Boolean kichHoat;
}
