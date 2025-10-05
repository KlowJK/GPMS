package com.backend.gpms.features.department.dto.request;

import lombok.*;
import lombok.experimental.FieldDefaults;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class TruongBoMonCreationRequest {

    Long giangVienId;
    Long boMonId;

}
