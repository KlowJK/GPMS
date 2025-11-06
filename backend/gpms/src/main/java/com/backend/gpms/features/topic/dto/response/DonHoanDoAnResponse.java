package com.backend.gpms.features.topic.dto.response;

import com.backend.gpms.features.topic.domain.TrangThaiDeTai;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDateTime;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class DonHoanDoAnResponse {
    Long id;

    Long sinhVienId;
    String hoTenSinhVien;
    String maSinhVien;
    String lopSinhVien;
    String nganhSinhVien;

    TrangThaiDeTai trangThai;
    String lyDo;
    String minhChungUrl;

    LocalDateTime updatedAt;
    LocalDateTime createdAt;

    Long nguoiPheDuyetId;
    String ghiChuQuyetDinh;
}