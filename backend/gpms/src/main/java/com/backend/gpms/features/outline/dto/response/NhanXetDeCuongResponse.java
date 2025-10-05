package com.backend.gpms.features.outline.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDate;
import java.util.List;

@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
public class NhanXetDeCuongResponse {
    String fileUrlMoiNhat;
    LocalDate ngayNopGanNhat;
    Integer tongSoLanNop;
    List<RejectNote> cacNhanXetTuChoi; // chỉ các lần bị từ chối trong quá khứ

    @Getter @Setter
    @NoArgsConstructor @AllArgsConstructor
    @FieldDefaults(level = lombok.AccessLevel.PRIVATE)
    public static class RejectNote {
        LocalDate ngayNhanXet; // createdAt của log
        String lyDo;
    }
}