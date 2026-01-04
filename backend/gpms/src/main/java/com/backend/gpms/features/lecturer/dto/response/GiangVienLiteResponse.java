package com.backend.gpms.features.lecturer.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class GiangVienLiteResponse {
    Long id;
    String hoTen;  // chỉ trả tên để render Select
    Long boMonId;
    Integer quotaInstruct;       // tối đa
    Long currentInstruct;        // đang hướng dẫn
    Integer remaining;

}
