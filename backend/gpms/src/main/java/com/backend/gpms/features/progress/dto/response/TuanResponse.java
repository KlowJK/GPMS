package com.backend.gpms.features.progress.dto.response;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter
@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TuanResponse {
    private String tuan;
    private LocalDateTime ngayBatDau;
    private LocalDateTime ngayKetThuc;
}