package com.backend.gpms.features.progress.dto.request;
import jakarta.validation.constraints.NotNull;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class DuyetNhatKyRequest {

    @NotNull(message = "NHAT_KY_ID_REQUIRED")
     Long id;
    @NotNull(message = "NHAN_XET_REQUIRED")
     String nhanXet;

}


