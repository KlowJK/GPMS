package com.backend.gpms.features.topic.dto.request;


import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;
import lombok.experimental.FieldDefaults;
import org.springframework.web.multipart.MultipartFile;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
public class DeTaiUpdateRequest {

    @NotNull(message = "MA_SINH_VIEN_REQUIRED")
    String maSinhVien;

    @NotBlank(message = "DE_TAI_TEN_REQUIRED")
    String tenDeTai;

    MultipartFile fileTongQuan;
}
