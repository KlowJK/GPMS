package com.backend.gpms.features.lecturer.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;


@Builder @Data @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class GiangVienProfileResponse {
    Long   id;
    String maGiangVien;
    String hoTen;
    String soDienThoai;
    String hocVi;
    String hocHam;
    String tenBoMon;
    String duongDanAvt;

    String email;
    Long   boMonId;
}