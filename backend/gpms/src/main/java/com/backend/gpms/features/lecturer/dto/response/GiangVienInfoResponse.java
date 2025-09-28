package com.backend.gpms.features.lecturer.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class GiangVienInfoResponse {

    String maGV;
    String hoTen;
    String hocVi;
    String hocHam;
    int soLuongDeTai;

}