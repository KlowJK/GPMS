package com.backend.gpms.features.progress.dto.response;

import jakarta.validation.constraints.NotNull;
import lombok.*;
import lombok.experimental.FieldDefaults;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class BaoCaoResponse {
    Long id;
    String idDeTai;
    String tenDeTai;
    String maSinhVien;
    String trangThai;
    int phienBan;
    LocalDateTime ngayNop;
    String duongDanFile;
    Double diemBaoCao;
    String tenGiangVienHuongDan;
    String nhanXet;

}
