package com.backend.gpms.features.score.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.FieldDefaults;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
public class DiemResponse {
    Long id;

    Long idSinhVien;
    String maSinhVien;
    String họTenSinhVien;

    Long idDeTai;
    String tenDeTai;

    Double diemBaoCao;
    Double diemPhanBien;
    Double diemHoiDong;

    String bienBan;
}