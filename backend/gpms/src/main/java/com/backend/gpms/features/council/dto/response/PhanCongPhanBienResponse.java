package com.backend.gpms.features.council.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;
import java.time.LocalDate;
import java.util.List;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class PhanCongPhanBienResponse {

    Long id;
    String tenHoiDong;
    String maSinhVien;
    String hoTen;
    String lop;
    String idDeTai;
    String tenDeTai;
    String gvhd;
    String idBoMon;
    String boMon;
    Double diemBaoCao;
    Double diemPhanBien;
    Double diemHoiDong;

    List<GiangVienChamDiem> giangVien;

    @Builder
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @FieldDefaults(level = AccessLevel.PRIVATE)
    public static class GiangVienChamDiem {
        Long idGiangVien;
        String hoTen;
        String maGiangVien;
        String vaiTro;
        String idBoMon;
        String boMon;
        Double diem;
        String nhanXet;
        String trangThai;
        String hopLe;
    }

}