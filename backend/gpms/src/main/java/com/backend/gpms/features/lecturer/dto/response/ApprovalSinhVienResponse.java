package com.backend.gpms.features.lecturer.dto.response;

import com.backend.gpms.features.topic.domain.TrangThaiDeTai;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)

public class ApprovalSinhVienResponse {
    String maSV;
    String hoTen;
    String tenLop;
    String soDienThoai;
    String tenDeTai;
    String idDeTai;
    TrangThaiDeTai trangThai;
    String tongQuanDeTaiUrl;
    String nhanXet;
}
