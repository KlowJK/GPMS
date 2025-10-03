package com.backend.gpms.features.topic.dto.response;

import com.backend.gpms.features.topic.domain.TrangThaiDeTai;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
public class DeTaiResponse {
    Long id;
    String tenDeTai;
    TrangThaiDeTai trangThai;
    String nhanXet;

    Long gvhdId;
    String gvhdTen;
    Long sinhVienId;

    String tongQuanDeTaiUrl;
    String tongQuanFilename;
}