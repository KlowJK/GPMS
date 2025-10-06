package com.backend.gpms.features.lecturer.application;

import com.backend.gpms.common.exception.ApplicationException;
import com.backend.gpms.common.exception.ErrorCode;
import com.backend.gpms.features.department.domain.BoMon;
import com.backend.gpms.features.department.domain.Khoa;
import com.backend.gpms.features.department.domain.Nganh;
import com.backend.gpms.features.department.infra.BoMonRepository;
import com.backend.gpms.features.department.infra.NganhRepository;
import com.backend.gpms.features.lecturer.domain.GiangVien;
import com.backend.gpms.features.lecturer.dto.response.GiangVienLiteResponse;
import com.backend.gpms.features.lecturer.infra.GiangVienLoad;
import com.backend.gpms.features.lecturer.infra.GiangVienRepository;
import com.backend.gpms.features.student.domain.SinhVien;
import com.backend.gpms.features.student.infra.SinhVienRepository;
import com.backend.gpms.features.topic.infra.DeTaiRepository;
import jakarta.transaction.Transactional;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;


@Service
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
@RequiredArgsConstructor
@Transactional
public class GiangVienService {

    private final SinhVienRepository sinhVienRepository;
    private final BoMonRepository boMonRepository;
    private final GiangVienRepository giangVienRepository;
    private final DeTaiRepository deTaiRepository;
    private final NganhRepository nganhRepository;

    public List<GiangVienLiteResponse> giangVienLiteResponseList() {

        String accountEmail = getCurrentUsername();
        SinhVien sinhVien = sinhVienRepository.findByUser_Email(accountEmail)
                .orElseThrow(() -> new ApplicationException(ErrorCode.SINH_VIEN_NOT_FOUND));
        
        if (sinhVien.getLop() == null) return List.of();


        Nganh nganh = nganhRepository.findById(sinhVien.getLop().getNganh().getId()).orElseThrow(()-> new ApplicationException(ErrorCode.NGANH_NOT_FOUND));
        if (nganh == null) return List.of();

        Khoa khoa = nganh.getKhoa();

        if (khoa == null) return List.of();

        // Lấy tất cả bộ môn thuộc khoa
        List<BoMon> boMonList = boMonRepository.findByKhoa_Id(khoa.getId());
        if (boMonList == null || boMonList.isEmpty()) {
            throw new ApplicationException(ErrorCode.BO_MON_NOT_FOUND);
        }

        // Lấy tất cả giảng viên thuộc các bộ môn này
        List<GiangVien> giangViens = new ArrayList<>();
        for (BoMon boMon : boMonList) {
            List<GiangVien> gvs = giangVienRepository.findByBoMon_Id(boMon.getId());
            if (gvs != null) giangViens.addAll(gvs);
        }
        if (giangViens.isEmpty()) {throw new ApplicationException(ErrorCode.GIANG_VIEN_NOT_FOUND);};

        // Đếm số đề tài đang hướng dẫn của từng GV (gom nhóm 1 query)
        List<Long> gvIds = giangViens.stream().map(GiangVien::getId).toList();
        Map<Long, Long> currentMap = deTaiRepository.countActiveByGiangVienIds(gvIds)
                .stream()
                .collect(Collectors.toMap(GiangVienLoad::getGiangVienId, GiangVienLoad::getSoDeTai));

        // Lọc những GV còn slot (current < quota_huong_dan)
        return giangViens.stream()
                .map(gv -> {
                    long current = currentMap.getOrDefault(gv.getId(), 0L);
                    int quota = Optional.ofNullable(gv.getQuotaInstruct()).orElse(0);
                    int remaining = (int) (quota - current);
                    if (remaining <= 0) return null;
                    return GiangVienLiteResponse.builder()
                            .id(gv.getId())
                            .hoTen(gv.getHoTen())
                            .boMonId(gv.getBoMon() != null ? gv.getBoMon().getId() : null)
                            .quotaInstruct(quota)
                            .currentInstruct(current)
                            .remaining(remaining)
                            .build();
                })
                .filter(Objects::nonNull)
                .sorted(Comparator.comparing(GiangVienLiteResponse::getRemaining).reversed()
                        .thenComparing(GiangVienLiteResponse::getHoTen))
                .toList();
    }

    private String getCurrentUsername() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        try { return auth.getName(); }
        catch (Exception e) { throw new ApplicationException(ErrorCode.UNAUTHENTICATED); }
    }
}
