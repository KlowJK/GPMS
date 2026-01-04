package com.backend.gpms.features.outline.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDateTime;


@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
public class NhanXetDeCuongResponse {
    String nhanXet;
    Long idGiangVien;
    String hoTenGiangVien;
    LocalDateTime createdAt;
}