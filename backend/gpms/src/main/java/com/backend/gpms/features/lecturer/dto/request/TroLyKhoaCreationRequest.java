package com.backend.gpms.features.lecturer.dto.request;

import lombok.*;
import lombok.experimental.FieldDefaults;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class TroLyKhoaCreationRequest {

    Long giangVienId;

}
