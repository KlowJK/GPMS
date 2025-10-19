package com.backend.gpms.features.outline.dto.response;


import com.backend.gpms.features.outline.domain.TrangThaiDeCuong;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDateTime;
import java.util.List;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class  DeCuongNhanXetResponse{

    Long id;
    String deCuongUrl;
    TrangThaiDeCuong trangThai;
    Integer phienBan;

    String tenDeTai;
    String maSV;
    String hoTenSinhVien;

    String hoTenGiangVienHuongDan;
    String hoTenGiangVienPhanBien;
    String hoTenTruongBoMon;

    String gvPhanBienDuyet;//
    String tbmDuyet;//

    List<NhanXetDeCuongResponse> nhanXets; // 0..n
    LocalDateTime createdAt;
}
