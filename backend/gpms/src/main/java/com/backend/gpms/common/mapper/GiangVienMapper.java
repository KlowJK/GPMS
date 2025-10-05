package com.backend.gpms.common.mapper;

import com.backend.gpms.features.department.domain.BoMon;
import com.backend.gpms.features.department.domain.Lop;
import com.backend.gpms.features.department.domain.Nganh;
import com.backend.gpms.features.department.infra.BoMonRepository;
import com.backend.gpms.features.department.infra.LopRepository;
import com.backend.gpms.features.department.infra.NganhRepository;
import com.backend.gpms.features.lecturer.domain.GiangVien;
import com.backend.gpms.features.lecturer.dto.request.GiangVienCreationRequest;


import com.backend.gpms.features.lecturer.dto.response.GiangVienLiteResponse;
import com.backend.gpms.features.lecturer.dto.response.GiangVienLookupResponse;
import com.backend.gpms.features.lecturer.infra.GiangVienLoad;
import com.backend.gpms.features.lecturer.infra.GiangVienRepository;
import com.backend.gpms.features.topic.infra.DeTaiRepository;
import org.apache.commons.collections4.CollectionUtils;
import org.mapstruct.*;

import java.util.*;
import java.util.stream.Collectors;

@Mapper(
        componentModel = "spring",
        unmappedSourcePolicy = ReportingPolicy.IGNORE,
        nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE
)
public interface GiangVienMapper {

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "boMon", ignore = true) // đúng tên field trong entity của bạn
    @Mapping(target = "user",   ignore = true)
    @Mapping(target = "duongDanAvt", ignore = true)
    GiangVien toGiangVien(GiangVienCreationRequest request);

    // MapStruct method: truyền repo vào để dùng ở @AfterMapping
    @Mapping(target = "nganhId", ignore = true)
    @Mapping(target = "tenNganh", ignore = true)
    @Mapping(target = "boMonId", ignore = true)
    @Mapping(target = "tenBoMon", ignore = true)
    @Mapping(target = "giangVienKhaDung", ignore = true)
    GiangVienLookupResponse fromLopId(Long lopId,
                                      LopRepository lopRepo,
                                      NganhRepository nganhRepo,
                                      BoMonRepository boMonRepo,
                                      GiangVienRepository giangVienRepo,
                                      DeTaiRepository deTaiRepo);

    @AfterMapping
    default void resolveGraph(Long lopId,
                              @MappingTarget GiangVienLookupResponse out,
                              LopRepository lopRepo,
                              NganhRepository nganhRepo,
                              BoMonRepository boMonRepo,
                              GiangVienRepository giangVienRepo,
                              DeTaiRepository deTaiRepo) {
        // 1) Lấy Lớp
        Lop lop = lopRepo.findById(lopId)
                .orElseThrow(() -> new IllegalArgumentException("Lớp không tồn tại: id=" + lopId));
        out.setLopId(lopId);

        // 2) Từ Lớp → Ngành
        // Tuỳ entity của bạn: có thể là lop.getNganh() hoặc getIdNganh()
        Nganh nganh = null;
        try {
            // nếu có mapping ManyToOne
            var g = lop.getClass().getMethod("getNganh").invoke(lop);
            if (g instanceof Nganh ng) nganh = ng;
        } catch (Exception ignored) {}
        if (nganh == null) {
            // fallback: nếu bạn lưu FK dạng Long idNganh
            try {
                var m = lop.getClass().getMethod("getIdNganh");
                Object idNganhObj = m.invoke(lop);
                if (idNganhObj instanceof Long idNganh) {
                    nganh = nganhRepo.findById(idNganh)
                            .orElseThrow(() -> new IllegalArgumentException("Ngành không tồn tại: id=" + idNganh));
                }
            } catch (Exception e) {
                throw new IllegalStateException("Không lấy được ngành từ Lớp. Hãy đảm bảo Lop có field 'nganh' hoặc 'idNganh'.");
            }
        }
        out.setNganhId(nganh.getId());
        out.setTenNganh(nganh.getTenNganh());

        // 3) Từ Ngành → Bộ môn
        BoMon boMon = null;
        try {
            var bm = nganh.getClass().getMethod("getBoMon").invoke(nganh);
            if (bm instanceof BoMon b) boMon = b;
        } catch (Exception ignored) {}
        if (boMon == null) {
            try {
                var m = nganh.getClass().getMethod("getIdBoMon");
                Object idBmObj = m.invoke(nganh);
                if (idBmObj instanceof Long idBm) {
                    boMon = boMonRepo.findById(idBm)
                            .orElseThrow(() -> new IllegalArgumentException("Bộ môn không tồn tại: id=" + idBm));
                }
            } catch (Exception e) {
                throw new IllegalStateException("Không lấy được bộ môn từ Ngành. Hãy đảm bảo Nganh có field 'boMon' hoặc 'idBoMon'.");
            }
        }
        out.setBoMonId(boMon.getId());
        out.setTenBoMon(boMon.getTenBoMon());

        // 4) Lấy giảng viên thuộc bộ môn
        List<GiangVien> giangViens = giangVienRepo.findAllByBoMon_Id(boMon.getId());
        if (CollectionUtils.isEmpty(giangViens)) {
            out.setGiangVienKhaDung(List.of());
            return;
        }

        // 5) Đếm số đề tài đang hướng dẫn của từng GV (gom nhóm 1 query)
        List<Long> gvIds = giangViens.stream().map(GiangVien::getId).toList();
        Map<Long, Long> currentMap = deTaiRepo.countActiveByGiangVienIds(gvIds)
                .stream()
                .collect(Collectors.toMap(GiangVienLoad::getGiangVienId, GiangVienLoad::getSoDeTai));

        // 6) Lọc những GV còn slot (current < quota_huong_dan)
        List<GiangVienLiteResponse> options = giangViens.stream()
                .map(gv -> {
                    long current = currentMap.getOrDefault(gv.getId(), 0L);
                    int quota = Optional.ofNullable(gv.getQuotaInstruct()).orElse(0);
                    int remaining = (int) (quota - current);
                    if (remaining <= 0) return null;

                    return GiangVienLiteResponse.builder()
                            .id(gv.getId())
                            .hoTen(gv.getHoTen())
                            .quotaInstruct(quota)
                            .currentInstruct(current)
                            .remaining(remaining)
                            .build();
                })
                .filter(Objects::nonNull)
                .sorted(Comparator.comparing(GiangVienLiteResponse::getRemaining).reversed()
                        .thenComparing(GiangVienLiteResponse::getHoTen))
                .toList();

        out.setGiangVienKhaDung(options);
    }


}