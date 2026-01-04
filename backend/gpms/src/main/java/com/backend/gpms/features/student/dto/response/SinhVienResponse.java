package com.backend.gpms.features.student.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
@JsonInclude(JsonInclude.Include.NON_EMPTY)
public class SinhVienResponse {

    String maSV;
    String hoTen;
    String soDienThoai;
    String email;
    String tenLop;
    boolean kichHoat;

}
