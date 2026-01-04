package com.backend.gpms.features.notification.dto.request;

import lombok.*;
import lombok.experimental.FieldDefaults;
import org.springframework.web.multipart.MultipartFile;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ThongBaoRequest {
    String tieuDe;
    String noiDung;
    MultipartFile file;
    Long kieuNguoiNhan;
    String loaiThongBao;
}
