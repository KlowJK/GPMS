package com.backend.gpms.features.progress.dto.response;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class SinhVienSupervisedResponse {
    String maSV;
    String hoTen;
    String tenLop;
    String tenDeTai;
    String trangThaiBaoCao;
}
