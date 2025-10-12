package com.backend.gpms.features.progress.application;
import com.backend.gpms.common.exception.ApplicationException;
import com.backend.gpms.common.exception.ErrorCode;
import com.backend.gpms.common.mapper.NhatKyTienTrinhMapper;
import com.backend.gpms.features.defense.domain.DotBaoVe;
import com.backend.gpms.features.lecturer.infra.GiangVienRepository;
import com.backend.gpms.features.progress.domain.NhatKyTienTrinh;
import com.backend.gpms.features.progress.dto.request.DuyetNhatKyRequest;
import com.backend.gpms.features.progress.dto.request.NhatKyTienTrinhRequest;
import com.backend.gpms.features.progress.dto.response.NhatKyTienTrinhResponse;
import com.backend.gpms.features.progress.dto.response.TuanResponse;
import com.backend.gpms.features.progress.infra.NhatKyTienTrinhRepository;
import com.backend.gpms.features.storage.application.CloudinaryStorageService;
import com.backend.gpms.features.storage.application.StorageService;

import com.backend.gpms.features.topic.domain.DeTai;
import com.backend.gpms.features.topic.domain.TrangThaiDeTai;
import com.backend.gpms.features.topic.infra.DeTaiRepository;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;


import java.io.IOException;
import java.time.*;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

@Service
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
@RequiredArgsConstructor
@jakarta.transaction.Transactional
public class NhatKyTienTrinhService {

    private static final Logger log = LoggerFactory.getLogger(NhatKyTienTrinhService.class);
    private NhatKyTienTrinhRepository nhatKyRepository;

    private DeTaiRepository deTaiRepository;

    private NhatKyTienTrinhMapper mapper;

    private CloudinaryStorageService cloudinaryService;

    private final GiangVienRepository giangVienRepository;


    private LocalDateTime getNgayDuyetDeTai(DeTai deTai) {
        if (deTai.getTrangThai() != TrangThaiDeTai.DA_DUYET) {
            throw new ApplicationException(ErrorCode.DE_TAI_NOT_ACCEPTED);
        }
        return deTai.getUpdatedAt();
    }

    // Tính tuần và ngày bắt đầu/kết thúc tuần dựa trên ngày nộp hiện tại
    private TuanInfo calculateTuanInfo(DeTai deTai, LocalDateTime ngayNop) {
        LocalDateTime ngayDuyet = getNgayDuyetDeTai(deTai);
        DotBaoVe dotBaoVe = deTai.getDotBaoVe();
        LocalDateTime ngayKetThucDot = dotBaoVe.getNgayKetThuc().atStartOfDay();

        if (ngayNop.toLocalDate().isAfter(ngayKetThucDot.toLocalDate())) {
            throw new RuntimeException("Qua han nop");
        }

        long weeks = ChronoUnit.WEEKS.between(ngayDuyet.truncatedTo(ChronoUnit.DAYS), ngayNop.truncatedTo(ChronoUnit.DAYS)) + 1;

        String tuan = "Tuần " + weeks;

        // Tính ngày bắt đầu tuần: thứ 2 của tuần đó, nhưng đơn giản dùng ngayDuyet + (weeks-1)*7
        LocalDateTime startOfWeek = ngayDuyet.plusWeeks(weeks - 1).with(DayOfWeek.MONDAY).toLocalDate().atStartOfDay(); // Giả sử tuần bắt đầu thứ 2
        LocalDateTime endOfWeek = startOfWeek.plusDays(6).withHour(23).withMinute(59).withSecond(59);

        if (endOfWeek.isAfter(ngayKetThucDot)) {
            endOfWeek = ngayKetThucDot;
        }

        TuanInfo info = new TuanInfo();
        info.tuan = tuan;
        info.ngayBatDau = startOfWeek;
        info.ngayKetThuc = endOfWeek;
        return info;
    }

    // Class helper
    private static class TuanInfo {
        String tuan;
        LocalDateTime ngayBatDau;
        LocalDateTime ngayKetThuc;
    }

    // Lấy danh sách tuần dựa trên ngày duyệt đến ngày kết thúc
    public List<TuanResponse> getTuanList(Long deTaiId) {
        DeTai deTai = deTaiRepository.findById(deTaiId)
                .orElseThrow(() -> new RuntimeException("DeTai not found"));
        LocalDateTime ngayDuyet = getNgayDuyetDeTai(deTai);
        LocalDateTime ngayKetThuc = deTai.getDotBaoVe().getNgayKetThuc().atStartOfDay();

        long totalWeeks = ChronoUnit.WEEKS.between(ngayDuyet.toLocalDate(), ngayKetThuc.toLocalDate()) + 1;

        List<TuanResponse> tuanList = new ArrayList<>();
        for (int i = 1; i <= totalWeeks; i++) {
            String tuan = "Tuần " + i;
            LocalDateTime start = ngayDuyet.plusWeeks(i - 1).with(DayOfWeek.MONDAY).toLocalDate().atStartOfDay();
            LocalDateTime end = start.plusDays(6).withHour(23).withMinute(59).withSecond(59);
            if (end.isAfter(ngayKetThuc)) {
                end = ngayKetThuc;
            }
            TuanResponse response = new TuanResponse();
            response.setTuan(tuan);
            response.setNgayBatDau(start);
            response.setNgayKetThuc(end);
            tuanList.add(response);
        }
        return tuanList;
    }

    // Lấy list nhật ký
    public List<NhatKyTienTrinhResponse> getNhatKyList() {
        String email = getCurrentUsername();
        DeTai deTai = deTaiRepository
                .findBySinhVien_User_EmailIgnoreCase(email)
                .orElseThrow(() -> new ApplicationException(ErrorCode.DE_TAI_NOT_FOUND));

        Long idDeTai=deTai.getId();
        List<NhatKyTienTrinh> entities = nhatKyRepository.findByDeTai_IdOrderByCreatedAt(idDeTai);
        return mapper.toResponseList(entities);
    }

    public Page<NhatKyTienTrinhResponse> getNhatKyPage(Pageable pageable) {
        String email = getCurrentUsername();
        Long gvhdId = giangVienRepository.findByUser_Email(email)
                .orElseThrow(() -> new ApplicationException(ErrorCode.NOT_A_GVHD))
                .getId();

        Page<NhatKyTienTrinh> entities = nhatKyRepository.findByGiangVienHuongDan_IdAndTrangThaiNhatKyOrderByCreatedAt(gvhdId, TrangThaiDeTai.CHO_DUYET,pageable);
        return mapper.toResponsePage(entities);
    }

    // Nộp nhật ký, tự tính tuần
    public NhatKyTienTrinhResponse nopNhatKy(NhatKyTienTrinhRequest request)  {
        String email = getCurrentUsername();

        DeTai deTai = deTaiRepository
                .findBySinhVien_User_EmailIgnoreCase(email)
                .orElseThrow(() -> new ApplicationException(ErrorCode.DE_TAI_NOT_FOUND));

        LocalDateTime ngayNop = LocalDateTime.now();

        TuanInfo tuanInfo = calculateTuanInfo(deTai, ngayNop);
        NhatKyTienTrinh entity = new  NhatKyTienTrinh();
        entity.setDeTai(deTai);
        entity.setNoiDung(request.getNoiDung());
        entity.setTuan(tuanInfo.tuan);
        entity.setNgayBatDau(tuanInfo.ngayBatDau);
        entity.setNgayKetThuc(tuanInfo.ngayKetThuc);
        entity.setGiangVienHuongDan(deTai.getGiangVienHuongDan());
        entity.setTrangThaiNhatKy(TrangThaiDeTai.CHO_DUYET);

        if (request.getDuongDanFile() != null && !request.getDuongDanFile().isEmpty()) {
            String url = upload(request.getDuongDanFile());
            entity.setDuongDanFile(url);
        }

        return mapper.toResponse(nhatKyRepository.save(entity));
    }

    public NhatKyTienTrinhResponse duyetNhatKy(Long id, DuyetNhatKyRequest request) {

        NhatKyTienTrinh entity = nhatKyRepository.findById(id)
                .orElseThrow(() -> new ApplicationException(ErrorCode.NHAT_KY_NOT_FOUND));

        entity.setTrangThaiNhatKy(TrangThaiDeTai.DA_DUYET);
        entity.setNhanXet(request.getNhanXet());
        NhatKyTienTrinh saved = nhatKyRepository.save(entity);

        return mapper.toResponse(saved);
    }


    private String getCurrentUsername() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        try { return auth.getName(); }
        catch (Exception e) { throw new ApplicationException(ErrorCode.UNAUTHENTICATED); }
    }

    private String upload(MultipartFile file) {
        try { return cloudinaryService.upload(file); }
        catch (Exception e) {
            log.error("Upload file failed: {}", e.getMessage(), e);
            throw new ApplicationException(ErrorCode.UPLOAD_FILE_FAILED);
        }
    }
}