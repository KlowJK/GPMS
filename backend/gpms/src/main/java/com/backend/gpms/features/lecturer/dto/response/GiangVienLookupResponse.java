package com.backend.gpms.features.lecturer.dto.response;

import lombok.*;
import java.util.List;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class GiangVienLookupResponse {
    private Long lopId;

    private Long   nganhId;
    private String tenNganh;

    private Long   boMonId;
    private String tenBoMon;

    // danh sách GV còn slot hướng dẫn
    private List<GiangVienLiteResponse> giangVienKhaDung;
}