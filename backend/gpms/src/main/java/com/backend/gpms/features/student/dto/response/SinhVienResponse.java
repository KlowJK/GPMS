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


    private Ref nganh;
    private Ref lop;
    private Long userId;

    private Boolean kichHoat;

    @Getter @Setter
    @NoArgsConstructor @AllArgsConstructor @Builder
    public static class Ref {
        private Long id;
        private String ma;     // ví dụ: mã ngành, mã lớp
        private String ten;
    }
}
