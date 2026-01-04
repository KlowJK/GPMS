package com.backend.gpms.features.department.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class BoMonWithTruongBoMonResponse {
    Long id;
    String tenBoMon;

    Long khoaId;
    String tenKhoa;

    // chỉ tên TBM hiện tại, có thể null nếu chưa phân công
    String truongBoMonHoTen;
}