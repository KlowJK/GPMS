package com.backend.gpms.features.council.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;

import java.util.List;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class PhanCongBaoVeResponse {
    int totalRecords;
    int successCount;
    int failureCount;
    List<FailureItem> failureItems;
    String logFileUrl;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class FailureItem {
        String maSinhVien;
        String tenDeTai;
        String reason;
    }
}