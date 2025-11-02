package com.backend.gpms.features.storage.dto.response;

import com.backend.gpms.features.council.dto.response.PhanCongPhanBienResponse;
import lombok.*;
import lombok.experimental.FieldDefaults;
import org.apache.commons.math3.geometry.partitioning.BSPTree;

import java.util.List;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
public class ThuVienDeTaiResponse {
    Long id;
    String deTai;
    String duongDan;
    Long idDotBaoVe;
    String namHoc;
    String hocKy;

    List<DeCuongCuaDeTai> deCuongCuaDeTai;

    @Builder
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @FieldDefaults(level = AccessLevel.PRIVATE)
    public static class DeCuongCuaDeTai {
        Long id;
        String duongDan;
        String phienBan;
    }
}