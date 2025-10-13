package com.backend.gpms.features.progress.application;
import com.backend.gpms.common.exception.ApplicationException;
import com.backend.gpms.common.exception.ErrorCode;
import com.backend.gpms.common.mapper.NhatKyTienTrinhMapper;
import com.backend.gpms.features.defense.domain.DotBaoVe;
import com.backend.gpms.features.lecturer.infra.GiangVienRepository;
import com.backend.gpms.features.progress.domain.NhatKyTienTrinh;
import com.backend.gpms.features.progress.domain.TrangThaiNhatKy;
import com.backend.gpms.features.progress.dto.request.DuyetNhatKyRequest;
import com.backend.gpms.features.progress.dto.request.NhatKyTienTrinhRequest;
import com.backend.gpms.features.progress.dto.response.NhatKyTienTrinhResponse;
import com.backend.gpms.features.progress.dto.response.TuanResponse;
import com.backend.gpms.features.progress.infra.NhatKyTienTrinhRepository;
import com.backend.gpms.features.storage.application.CloudinaryStorageService;
import com.backend.gpms.features.topic.domain.DeTai;
import com.backend.gpms.features.topic.domain.TrangThaiDeTai;
import com.backend.gpms.features.topic.infra.DeTaiRepository;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;



import java.time.*;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Service
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
@RequiredArgsConstructor
@jakarta.transaction.Transactional
public class NhatKyTienTrinhService {

    private static final Logger log = LoggerFactory.getLogger(NhatKyTienTrinhService.class);
     NhatKyTienTrinhRepository nhatKyRepository;

   DeTaiRepository deTaiRepository;

     NhatKyTienTrinhMapper nhatKyTienTrinhMapper;

   CloudinaryStorageService cloudinaryService;

     final GiangVienRepository giangVienRepository;

    LocalDateTime currentDate = LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh"));


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


    public List<TuanResponse> getTuanList(boolean all) {
        String email = getCurrentUsername();
        DeTai deTai = deTaiRepository
                .findBySinhVien_User_EmailIgnoreCase(email)
                .orElseThrow(() -> new ApplicationException(ErrorCode.DE_TAI_NOT_FOUND));

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

            // Chỉ thêm tuần nếu all = true hoặc ngayBatDau < currentDate
            if (all || start.isBefore(currentDate) && end.isAfter(currentDate)) {
                TuanResponse response = new TuanResponse();
                response.setTuan(tuan);
                response.setNgayBatDau(start);
                response.setNgayKetThuc(end);
                tuanList.add(response);
            }
        }
        return tuanList;
    }

    public List<TuanResponse> getTuanListByGVHD(boolean includeAll) {
        String email = getCurrentUsername();
        Long gvhdId = giangVienRepository.findByUser_Email(email)
                .orElseThrow(() -> new ApplicationException(ErrorCode.NOT_A_GVHD))
                .getId();

        List<DeTai> deTais = deTaiRepository.findByGiangVienHuongDan_IdAndTrangThai(gvhdId, TrangThaiDeTai.DA_DUYET, Pageable.unpaged()).getContent();

        List<TuanResponse> tuanList = new ArrayList<>();
        for (DeTai deTai : deTais) {
            LocalDateTime ngayDuyet = getNgayDuyetDeTai(deTai);
            LocalDateTime ngayKetThuc = deTai.getDotBaoVe().getNgayKetThuc().atStartOfDay();

            long totalWeeks = ChronoUnit.WEEKS.between(ngayDuyet.toLocalDate(), ngayKetThuc.toLocalDate()) + 1;

            for (int i = 1; i <= totalWeeks; i++) {
                String tuan = "Tuần " + i;
                LocalDateTime start = ngayDuyet.plusWeeks(i - 1).with(DayOfWeek.MONDAY).toLocalDate().atStartOfDay();
                LocalDateTime end = start.plusDays(6).withHour(23).withMinute(59).withSecond(59);
                if (end.isAfter(ngayKetThuc)) {
                    end = ngayKetThuc;
                }

                // Chỉ thêm tuần nếu ngày bắt đầu của tuần đó chưa qua ngày hiện tại
                if (includeAll || start.isBefore(currentDate) && end.isAfter(currentDate)) {
                    TuanResponse response = new TuanResponse();
                    response.setTuan(tuan);
                    response.setNgayBatDau(start);
                    response.setNgayKetThuc(end);
                    tuanList.add(response);
                }
            }
        }
        return tuanList;
    }

    public Page<NhatKyTienTrinhResponse> getNhatKyTienTrinhPage(String tuanInput, Pageable pageable) {
        String email = getCurrentUsername();
        List<DeTai> deTais = deTaiRepository.findByGiangVienHuongDan_User_EmailIgnoreCase(email);

        if (deTais.isEmpty()) {
            throw new ApplicationException(ErrorCode.DE_TAI_NOT_FOUND);
        }

        // Xử lý trường hợp tuanInput là null, mặc định lấy tất cả
        if (tuanInput == null) {
            tuanInput = "all";
        }

        // Lấy tất cả nhật ký tiến trình từ các đề tài
        List<NhatKyTienTrinh> allNhatKys = new ArrayList<>();
        for (DeTai deTai : deTais) {
            Long idDeTai = deTai.getId();
            LocalDateTime ngayDuyet = getNgayDuyetDeTai(deTai);
            LocalDateTime ngayKetThuc = deTai.getDotBaoVe().getNgayKetThuc().atStartOfDay();

            // Lấy danh sách tuần cho đề tài hiện tại
            List<TuanResponse> tuanList = getTuanList(idDeTai);

            // Tìm tuần tương ứng với tuanInput
            TuanResponse selectedTuan = null;
            if ("all".equalsIgnoreCase(tuanInput)) {
                selectedTuan = null; // Sử dụng null để lấy tất cả
            } else {
                for (TuanResponse tuan : tuanList) {
                    if (tuan.getTuan().equalsIgnoreCase(tuanInput)) {
                        selectedTuan = tuan;
                        break;
                    }
                }
                if (selectedTuan == null) {
                    throw new ApplicationException(ErrorCode.INVALID_WEEK_NUMBER);
                }
            }

            LocalDateTime startDate = selectedTuan != null ? selectedTuan.getNgayBatDau().minusDays(1) : ngayDuyet;
            LocalDateTime endDate = selectedTuan != null ? selectedTuan.getNgayKetThuc().minusDays(1) : ngayKetThuc;

            // Lấy danh sách nhật ký tiến trình theo tuần cho đề tài hiện tại
            Page<NhatKyTienTrinh> nhatKyPage = nhatKyRepository.findByDeTai_IdAndNgayBatDauBetween(
                    idDeTai,
                    startDate,
                    endDate,
                    pageable
            );

            allNhatKys.addAll(nhatKyPage.getContent());
        }

        // Phân trang lại danh sách kết hợp
        int start = (int) pageable.getOffset();
        int end = Math.min((start + pageable.getPageSize()), allNhatKys.size());
        List<NhatKyTienTrinh> pagedNhatKys;
        if (start >= allNhatKys.size()) {
            pagedNhatKys = Collections.emptyList();
        } else if (end > allNhatKys.size()) {
            pagedNhatKys = allNhatKys.subList(start, allNhatKys.size());
        } else {
            pagedNhatKys = allNhatKys.subList(start, end);
        }
        int totalPages = (int) Math.ceil((double) allNhatKys.size() / pageable.getPageSize());

        return new PageImpl<>(
                pagedNhatKys.stream().map(nhatKyTienTrinhMapper::toNhatKyTienTrinhResponse).collect(Collectors.toList()),
                pageable,
                allNhatKys.size()
        );
    }


    // Lấy danh sách tuần dựa trên ngày duyệt đến ngày kết thúc
    public List<TuanResponse> getTuanList(Long deTaiId) {

        DeTai deTai = deTaiRepository.findById(deTaiId)
                .orElseThrow(() -> new ApplicationException(ErrorCode.DE_TAI_NOT_FOUND));

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
    public List<NhatKyTienTrinhResponse> getNhatKyList(boolean all) {
        String email = getCurrentUsername();
        DeTai deTai = deTaiRepository
                .findBySinhVien_User_EmailIgnoreCase(email)
                .orElseThrow(() -> new ApplicationException(ErrorCode.DE_TAI_NOT_FOUND));

        Long idDeTai=deTai.getId();

        List<NhatKyTienTrinh> entities = (all) ?
                nhatKyRepository.findByDeTai_IdOrderByCreatedAtDesc(idDeTai) :
                nhatKyRepository.findByDeTai_IdAndNgayBatDauBeforeOrderByCreatedAtDesc(idDeTai, currentDate);
        return nhatKyTienTrinhMapper.toResponseList(entities);
    }

    public Page<NhatKyTienTrinhResponse> getNhatKyPage(TrangThaiNhatKy status, Pageable pageable) {
        String email = getCurrentUsername();
        Long gvhdId = giangVienRepository.findByUser_Email(email)
                .orElseThrow(() -> new ApplicationException(ErrorCode.NOT_A_GVHD))
                .getId();

        Page<NhatKyTienTrinh> page = (status == null)
                ? nhatKyRepository.findByGiangVienHuongDan_IdOrderByCreatedAt(gvhdId,pageable)
                : nhatKyRepository.findByGiangVienHuongDan_IdAndTrangThaiNhatKyOrderByCreatedAt(gvhdId, status,pageable);
        return page.map(nhatKyTienTrinhMapper::toNhatKyTienTrinhResponse) ;
    }

    public NhatKyTienTrinhResponse nopNhatKy(NhatKyTienTrinhRequest request)  {

        NhatKyTienTrinh entity = nhatKyRepository.findById(request.getIdNhatKy())
                .orElseThrow(() -> new ApplicationException(ErrorCode.NHAT_KY_NOT_FOUND));

        entity.setNoiDung(request.getNoiDung());
        entity.setTrangThaiNhatKy(TrangThaiNhatKy.DA_NOP);

        if (request.getDuongDanFile() != null && !request.getDuongDanFile().isEmpty()) {
            String url = upload(request.getDuongDanFile());
            entity.setDuongDanFile(url);
        }
        return nhatKyTienTrinhMapper.toNhatKyTienTrinhResponse(nhatKyRepository.save(entity));
    }

    public NhatKyTienTrinhResponse duyetNhatKy(DuyetNhatKyRequest request) {

        NhatKyTienTrinh entity = nhatKyRepository.findById(request.getId())
                .orElseThrow(() -> new ApplicationException(ErrorCode.NHAT_KY_NOT_FOUND));

        if (entity.getTrangThaiNhatKy() != TrangThaiNhatKy.DA_NOP) {
            throw new ApplicationException(ErrorCode.NHAT_KY_ALREADY_REVIEWED);
        }

        entity.setTrangThaiNhatKy(TrangThaiNhatKy.HOAN_THANH);
        entity.setNhanXet(request.getNhanXet());
        return nhatKyTienTrinhMapper.toNhatKyTienTrinhResponse( nhatKyRepository.save(entity));
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

