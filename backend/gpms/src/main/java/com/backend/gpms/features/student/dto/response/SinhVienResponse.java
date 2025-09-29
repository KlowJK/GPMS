package com.backend.gpms.features.student.dto.response;

import lombok.*;
import java.time.LocalDate;

@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SinhVienResponse {
    private Long id;
    private String hoTen;
    private String maSinhVien;
    private String soDienThoai;
    private String duongDanCV;
    private LocalDate ngaySinh;
    private String diaChi;

    // Chỉ expose thông tin tối thiểu của quan hệ
    private Ref nganh;
    private Ref lop;
    private Long userId;   // tránh nhúng toàn bộ User

    private Boolean kichHoat;   // hoặc enabled, nhưng thống nhất với domain

    @Getter @Setter
    @NoArgsConstructor @AllArgsConstructor @Builder
    public static class Ref {
        private Long id;
        private String ma;     // ví dụ: mã ngành, mã lớp
        private String ten;
    }
}
