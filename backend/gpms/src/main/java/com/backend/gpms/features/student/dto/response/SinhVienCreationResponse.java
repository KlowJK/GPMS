package com.backend.gpms.features.student.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class SinhVienCreationResponse {

    String maSV;
    String hoTen;
    String soDienThoai;
    String email;
    Long lopId;

}
