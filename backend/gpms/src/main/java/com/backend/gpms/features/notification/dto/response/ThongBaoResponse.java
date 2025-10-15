package com.backend.gpms.features.notification.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDateTime;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
@JsonInclude(JsonInclude.Include.NON_EMPTY)
public class ThongBaoResponse {

    String tieuDe;
    String noiDung;
    String fileUrl;
    LocalDateTime createdAt;
    String loaiThongBao;
}