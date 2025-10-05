package com.backend.gpms.features.defense.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.util.List;
@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
@JsonInclude(JsonInclude.Include.NON_EMPTY)
public class AddSinhVienToDotBaoVeResponse {

    int totalRecords;
    int successCount;
    int failureCount;
    List<FailureItem> failureItems;
    String logFileUrl;


    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    @FieldDefaults(level = AccessLevel.PRIVATE)
    public static class FailureItem {
        String maSinhVien;
        String tenDeTai;
        String reason;
    }
}
