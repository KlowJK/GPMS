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
    private Long id;
    private String tuan;
    private LocalDateTime ngayBatDau;
    private LocalDateTime ngayKetThuc;
    private String noiDung;
    private String duongDanFile;
    private String nhanXet;

}
