package com.backend.gpms.features.progress.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDateTime;

@Getter @Setter
@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
public class NhatKyTienTrinhResponse {
     Long id;
     String tuan;
     String deTai;
     String maSinhVien;
     String lop;
     Long idDeTai;
     String hoTen;
     LocalDateTime ngayBatDau;
     LocalDateTime ngayKetThuc;
     String trangThaiNhatKy;
     String noiDung;
     String duongDanFile;
     String nhanXet;

}
