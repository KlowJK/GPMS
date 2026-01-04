package com.backend.gpms.features.defense.dto.request;


import jakarta.validation.constraints.NotNull;
import lombok.*;
import lombok.experimental.FieldDefaults;
import org.springframework.web.multipart.MultipartFile;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class AddSinhVienToDotBaoVeRequest {

    MultipartFile dataFile;
    @NotNull(message = "NAM_HOC_EMPTY")
    String namHoc;
    @NotNull(message = "HOC_KI_EMPTY")
    String hocKi;

}