package com.backend.gpms.features.lecturer.dto.response;

import com.backend.gpms.features.auth.domain.Role;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class GiangVienCreationResponse {

    String maGV;
    String hoTen;
    String soDienThoai;
    String hocVi;
    String hocHam;
    String email;
    Role vaiTro;
    Long boMonId;

}
