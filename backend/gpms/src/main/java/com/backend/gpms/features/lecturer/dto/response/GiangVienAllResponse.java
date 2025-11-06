package com.backend.gpms.features.lecturer.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class GiangVienAllResponse {
    Long id;
    String maGiangVien;
    String hoTen;
    String hocVi;
    String hocHam;
}
