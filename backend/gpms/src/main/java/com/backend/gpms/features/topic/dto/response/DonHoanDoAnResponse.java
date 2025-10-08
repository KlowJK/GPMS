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

    TrangThaiDeTai trangThai;
    String lyDo;
    String minhChungUrl;

    LocalDateTime updatedAt;
    LocalDateTime createdAt;

    Long nguoiPheDuyetId;
    String ghiChuQuyetDinh;
}