package com.backend.gpms.features.lecturer.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;


@Builder @Data @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class GiangVienResponse {
    Long   id;
    String maGV;
    String hoTen;
    String soDienThoai;
    String hocVi;
    String hocHam;

    String email;
    Long   boMonId;
}