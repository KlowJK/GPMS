package com.backend.gpms.features.topic.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DeTaiGiangVienHuongDanResponse {
    private boolean success;
    private String message;
}
