package com.backend.gpms.features.outline.application;


import com.backend.gpms.common.exception.ApplicationException;
import com.backend.gpms.common.exception.ErrorCode;
import com.backend.gpms.common.mapper.DeCuongMapper;
import com.backend.gpms.features.defense.domain.CongViec;
import com.backend.gpms.features.defense.domain.ThoiGianThucHien;
import com.backend.gpms.features.defense.infra.ThoiGianThucHienRepository;
import com.backend.gpms.features.lecturer.domain.GiangVien;
import com.backend.gpms.features.lecturer.infra.GiangVienRepository;
import com.backend.gpms.features.outline.domain.DeCuong;
import com.backend.gpms.features.outline.domain.NhanXetDeCuong;
import com.backend.gpms.features.outline.domain.TrangThaiDeCuong;
import com.backend.gpms.features.outline.domain.TrangThaiDuyetDon;
import com.backend.gpms.features.outline.dto.request.DeCuongUploadRequest;
import com.backend.gpms.features.outline.dto.response.DeCuongNhanXetResponse;
import com.backend.gpms.features.outline.dto.response.DeCuongResponse;
import com.backend.gpms.features.outline.infra.DeCuongRepository;
import com.backend.gpms.features.outline.infra.NhanXetDeCuongRepository;
import com.backend.gpms.features.topic.domain.DeTai;
import com.backend.gpms.features.topic.domain.TrangThaiDeTai;
import com.backend.gpms.features.topic.infra.DeTaiRepository;
import com.backend.gpms.common.util.TimeGatekeeper;
import jakarta.transaction.Transactional;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.time.LocalDate;
import java.time.ZoneId;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
@RequiredArgsConstructor
@Transactional
public class DeCuongService {

    DeCuongRepository deCuongRepository;
    DeTaiRepository deTaiRepository;
    GiangVienRepository giangVienRepository;
    DeCuongMapper mapper;
    NhanXetDeCuongRepository deCuongLogRepository;
    ThoiGianThucHienRepository thoiGianThucHienRepository;
    TimeGatekeeper timeGatekeeper;

    private static final ZoneId ZONE_BKK = ZoneId.of("Asia/Bangkok");


    public DeCuongResponse submitDeCuong(DeCuongUploadRequest request) {
        // 1) Lấy email hiện hành
        final String email = currentUsername();

        // 2) Tìm DeTai thuộc về SV hiện hành (ràng buộc UNIQUE theo DB)
        DeTai deTai = deTaiRepository
                .findBySinhVien_User_EmailIgnoreCase(email)
                .orElseThrow(() -> new ApplicationException(ErrorCode.DE_TAI_NOT_FOUND));

        // 3) Kiểm tra trạng thái đề tài
        if (deTai.getTrangThai() != TrangThaiDeTai.DA_DUYET) {
            throw new ApplicationException(ErrorCode.DE_TAI_NOT_ACCEPTED);
        }

        // 4) Phải có đợt bảo vệ
        if (deTai.getDotBaoVe() == null) {
            throw new ApplicationException(ErrorCode.NO_ACTIVE_SUBMISSION_WINDOW);
        }

        // 5) Kiểm tra chỉ được nộp trong mốc NỘP_ĐỀ_CƯƠNG
        timeGatekeeper.assertWithinWindow(CongViec.NOP_DE_CUONG, deTai.getDotBaoVe());

        // 6) Lấy/chuẩn hóa URL
        final String finalUrl = toClickableUrl(request.getFileUrl());
        if (finalUrl == null || finalUrl.isBlank()) {
            throw new ApplicationException(ErrorCode.FILE_URL_EMPTY);
        }

        // 7) Tạo mới/cập nhật DeCuong theo SV hiện hành
        DeCuong dc = deCuongRepository
                .findFirstByDeTai_SinhVien_User_EmailIgnoreCaseOrderByCreatedAtDesc(email)
                .map(existing -> {
                    if (existing.getTrangThaiDeCuong() == TrangThaiDeCuong.DA_DUYET) {
                        throw new ApplicationException(ErrorCode.DE_CUONG_ALREADY_APPROVED);
                    }
                    DeCuong createdVersion = new DeCuong();
                    createdVersion.setDeTai(deTai);
                    createdVersion.setDuongDanFile(finalUrl);
                    createdVersion.setTrangThaiDeCuong(TrangThaiDeCuong.CHO_DUYET);
                    createdVersion.setPhienBan(existing.getPhienBan() + 1);
                    createdVersion.setGiangVienHuongDan(deTai.getGiangVienHuongDan());
                    return createdVersion;
                })
                .orElseGet(() -> {
                    DeCuong created = new DeCuong();
                    created.setDeTai(deTai);
                    created.setDuongDanFile(finalUrl);
                    created.setTrangThaiDeCuong(TrangThaiDeCuong.CHO_DUYET);
                    created.setGiangVienHuongDan(deTai.getGiangVienHuongDan());
                    created.setPhienBan(1);
                    return created;
                });

        // 8) Lưu DB & trả về response
        return mapper.toResponse(deCuongRepository.save(dc));
    }



    public List<DeCuongNhanXetResponse> viewDeCuongLog() {
        String email = currentUsername();
        List<DeCuong> deCuongs = deCuongRepository.findByDeTai_SinhVien_User_EmailIgnoreCase(email);
        if (deCuongs.isEmpty()) throw new ApplicationException(ErrorCode.DE_CUONG_NOT_FOUND);

        // Lấy trước toàn bộ nhận xét của các đề cương liên quan (tránh N+1)
        List<Long> ids = deCuongs.stream().map(DeCuong::getId).toList();
        List<NhanXetDeCuong> allComments = deCuongLogRepository.findByDeCuong_IdInOrderByCreatedAtAsc(ids);
        Map<Long, List<NhanXetDeCuong>> commentsByDeCuongId = allComments.stream().collect(Collectors.groupingBy(c -> c.getDeCuong().getId()));
        List<DeCuongNhanXetResponse> responses = mapper.toDeCuongNhanXetResponse(deCuongs);
        for (DeCuongNhanXetResponse res : responses) {
            List<NhanXetDeCuong> cList = commentsByDeCuongId.getOrDefault(res.getId(), List.of());
            res.setNhanXets(mapper.toNhanXetDeCuongResponse(cList));
        }
        return responses;
    }


    public DeCuongResponse reviewDeCuong(Long deCuongId, boolean approve, String reason) {
        String email = currentUsername();
        GiangVien gv = giangVienRepository.findByUser_EmailIgnoreCase(email)
                .orElseThrow(() -> new ApplicationException(ErrorCode.ACCESS_DENIED));

        DeCuong dc = deCuongRepository.findById(deCuongId)
                .orElseThrow(() -> new ApplicationException(ErrorCode.DE_CUONG_NOT_FOUND));

        DeTai deTai = dc.getDeTai();
        if (deTai == null || deTai.getDotBaoVe() == null) {
            throw new ApplicationException(ErrorCode.NO_ACTIVE_SUBMISSION_WINDOW);
        }

        // Lấy đợt bảo vệ hiện hành (nếu không có -> NOT_IN_DOT_BAO_VE)
        var currentDot = timeGatekeeper.getCurrentDotBaoVe();

        // Đảm bảo đề tài thuộc đúng đợt hiện hành
        if (!currentDot.getId().equals(deTai.getDotBaoVe().getId())) {
            throw new ApplicationException(ErrorCode.NOT_IN_DOT_BAO_VE);
        }

        // Chỉ GVHD
        if (deTai.getGiangVienHuongDan() == null || !deTai.getGiangVienHuongDan().getId().equals(gv.getId())) {
            throw new ApplicationException(ErrorCode.ACCESS_DENIED);
        }

        if (dc.getTrangThaiDeCuong() == TrangThaiDeCuong.DA_DUYET) {
            throw new ApplicationException(ErrorCode.DE_CUONG_ALREADY_APPROVED);
        }
        if (dc.getTrangThaiDeCuong() == TrangThaiDeCuong.TU_CHOI) {
            // Đã bị từ chối thì SV phải nộp lại (PENDING) rồi mới xét tiếp
            throw new ApplicationException(ErrorCode.DE_CUONG_ALREADY_REJECTED);
        }
        if (dc.getTrangThaiDeCuong() != TrangThaiDeCuong.CHO_DUYET) {
            throw new ApplicationException(ErrorCode.OUTLINE_NOT_PENDING);
        }

        if (approve) {
            dc.setTrangThaiDeCuong(TrangThaiDeCuong.DA_DUYET);
            var log = new NhanXetDeCuong();
            log.setDeCuong(dc);
            log.setNhanXet(reason.trim());
            log.setGiangVien(gv);
            deCuongLogRepository.save(log);
        } else {
            if (reason == null || reason.isBlank()) {
                throw new ApplicationException(ErrorCode.DE_CUONG_REASON_REQUIRED);
            }
            // Ghi log nhận xét từ chối
            var log = new NhanXetDeCuong();
            log.setDeCuong(dc);
            log.setNhanXet(reason.trim());
            log.setGiangVien(gv);
            deCuongLogRepository.save(log);

            dc.setTrangThaiDeCuong(TrangThaiDeCuong.TU_CHOI);
        }

        return mapper.toResponse(deCuongRepository.save(dc));
    }



    public Page<DeCuongResponse> getAllDeCuong(TrangThaiDeCuong status ,Pageable pageable) {
        Long activeDotId = timeGatekeeper.getCurrentDotBaoVe().getId();
        List<Long> activeDotIds = java.util.List.of(activeDotId);

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String email = auth.getName();
        boolean isGV = auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_GIANG_VIEN")
                        || a.getAuthority().equals("ROLE_TRUONG_BO_MON") || a.getAuthority().equals("ROLE_TRO_LY_KHOA"));

        TrangThaiDuyetDon statusFilter;
        if(status == null) {
            statusFilter = null;
        } else if (status == TrangThaiDeCuong.CHO_DUYET) {
            statusFilter = TrangThaiDuyetDon.CHO_DUYET;
        } else if(status == TrangThaiDeCuong.DA_DUYET) {
            statusFilter = TrangThaiDuyetDon.DA_DUYET;
        }else if(status == TrangThaiDeCuong.TU_CHOI) {
            statusFilter = TrangThaiDuyetDon.TU_CHOI;
        } else {
            throw new ApplicationException(ErrorCode.INVALID_ENUM_VALUE);
        }

        Page<DeCuong> page;
        if (status == null) {
            page = isGV
                ? deCuongRepository
                    .findByGiangVienHuongDan_User_EmailIgnoreCaseOrGiangVienPhanBien_User_EmailIgnoreCaseOrTruongBoMon_User_EmailIgnoreCaseAndDeTai_DotBaoVe_IdInOrderByCreatedAtDesc(email, email, email, activeDotIds, pageable)
                : deCuongRepository
                    .findByDeTai_DotBaoVe_IdIn(activeDotIds, pageable);
        } else {
            page = isGV
                ? deCuongRepository
                    .findOutlineWithAnyStatus(email, email, email, activeDotIds, status, statusFilter, statusFilter, pageable)
                : deCuongRepository
                    .findByDeTai_DotBaoVe_IdIn(activeDotIds, pageable);
        }
        return page.map(mapper::toResponse);
    }




    public Page<DeCuongResponse> getAcceptedForTBM(Pageable pageable) {
        // 1) Lấy danh sách dot đang mở
        Long activeDotId = timeGatekeeper.getCurrentDotBaoVe().getId();
        List<Long> activeDotIds = java.util.List.of(activeDotId);

        // 2) Lấy bộ môn của TBM
        Long bmId = currentTBMBoMonId();

        // 3) Trả về chỉ các đề cương đã ACCEPTED trong các đợt đang mở
        return deCuongRepository
                .findByTrangThaiDeCuongAndDeTai_BoMon_IdAndDeTai_DotBaoVe_IdIn(
                        TrangThaiDeCuong.DA_DUYET, bmId, activeDotIds, pageable)
                .map(mapper::toResponse);
    }


    public byte[] exportAcceptedForTBMAsExcel() {
        // 1) Lấy danh sách dot đang mở
        Long activeDotId = timeGatekeeper.getCurrentDotBaoVe().getId();
        List<Long> activeDotIds = java.util.List.of(activeDotId);

        // 2) Lấy bộ môn của TBM
        Long bmId = currentTBMBoMonId();

        // 3) Dataset xuất file = đúng dataset của getAcceptedForTBM (không lọc updatedAt thủ công nữa)
        List<DeCuong> list = deCuongRepository
                .findByTrangThaiDeCuongAndDeTai_BoMon_IdAndDeTai_DotBaoVe_IdIn(
                        TrangThaiDeCuong.DA_DUYET, bmId, activeDotIds);

        try (var wb = new org.apache.poi.xssf.usermodel.XSSFWorkbook()) {
            var sheet = wb.createSheet("danh_sach_de_cuong_duoc_duyet");

            var headerStyle = wb.createCellStyle();
            var bold = wb.createFont(); bold.setBold(true);
            headerStyle.setFont(bold);

            var linkStyle = wb.createCellStyle();
            var linkFont = wb.createFont();
            linkFont.setUnderline(org.apache.poi.ss.usermodel.Font.U_SINGLE);
            linkFont.setColor(org.apache.poi.ss.usermodel.IndexedColors.BLUE.getIndex());
            linkStyle.setFont(linkFont);

            var helper = wb.getCreationHelper();

            String[] headers = {"Mã sinh viên","Họ và tên","Lớp","GVHD","Tên đề tài","Bộ môn quản lý","File URL"};
            var row0 = sheet.createRow(0);
            for (int i = 0; i < headers.length; i++) {
                var c = row0.createCell(i);
                c.setCellValue(headers[i]);
                c.setCellStyle(headerStyle);
            }

            int r = 1;
            for (DeCuong dc : list) {
                var dt = dc.getDeTai();
                var sv = dt != null ? dt.getSinhVien() : null;
                var lop = (sv != null && sv.getLop() != null) ? sv.getLop().getTenLop() : "";
                var gv  = (dt != null && dt.getGiangVienHuongDan() != null) ? dt.getGiangVienHuongDan().getHoTen() : "";
                var bm  = (dt != null && dt.getBoMon() != null) ? dt.getBoMon().getTenBoMon() : "";
                var fileUrl = dc.getDuongDanFile();

                var row = sheet.createRow(r++);
                row.createCell(0).setCellValue(sv != null ? nvl(sv.getMaSinhVien()) : "");
                row.createCell(1).setCellValue(sv != null ? nvl(sv.getHoTen()) : "");
                row.createCell(2).setCellValue(nvl(lop));
                row.createCell(3).setCellValue(nvl(gv));
                row.createCell(4).setCellValue(dt != null ? nvl(dt.getTenDeTai()) : "");
                row.createCell(5).setCellValue(nvl(bm));

                var linkCell = row.createCell(6);
                if (fileUrl != null && !fileUrl.isBlank()) {
                    String address = toClickableUrl(fileUrl);
                    var hyperlink = helper.createHyperlink(
                            address.startsWith("http") || address.startsWith("file:")
                                    ? org.apache.poi.common.usermodel.HyperlinkType.URL
                                    : org.apache.poi.common.usermodel.HyperlinkType.FILE
                    );
                    hyperlink.setAddress(address);
                    linkCell.setCellValue("Mở file");
                    linkCell.setHyperlink(hyperlink);
                    linkCell.setCellStyle(linkStyle);
                } else {
                    linkCell.setCellValue("");
                }
            }

            for (int i = 0; i < headers.length; i++) sheet.autoSizeColumn(i);

            try (ByteArrayOutputStream bos = new ByteArrayOutputStream()) {
                wb.write(bos);
                return bos.toByteArray();
            }
        } catch (IOException e) {
            throw new ApplicationException(ErrorCode.INTERNAL_SERVER_ERROR);
        }
    }

    // ===== helpers =====

    /** Lấy danh sách dot_bao_ve_id đang mở NOP_DE_CUONG hôm nay. Nếu không có → ném lỗi **/
    private List<Long> activeSubmissionDotIdsToday() {
        LocalDate today = LocalDate.now(ZONE_BKK);
        List<ThoiGianThucHien> open = thoiGianThucHienRepository
                .findAllByCongViecAndThoiGianBatDauLessThanEqualAndThoiGianKetThucGreaterThanEqual(
                        CongViec.NOP_DE_CUONG, today, today);

        if (open.isEmpty()) {
            throw new ApplicationException(ErrorCode.NO_ACTIVE_REVIEW_LIST);
        }

        return open.stream()
                .map(t -> t.getDotBaoVe().getId())
                .distinct()
                .toList();
    }

    private static String toClickableUrl(String input) {
        String s = input.trim();
        if (s.startsWith("http://") || s.startsWith("https://") || s.startsWith("file:")) {
            return s;
        }
        try {
            java.nio.file.Path p = java.nio.file.Paths.get(s);
            return p.toUri().toString();
        } catch (Exception e) {
            return s;
        }
    }

    private static String nvl(String s) {
        return s == null ? "" : s;
    }

    private String currentUsername() {
        return SecurityContextHolder.getContext().getAuthentication().getName();
    }

    private Long currentTBMBoMonId() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        GiangVien gv = giangVienRepository.findByUser_EmailIgnoreCase(email)
                .orElseThrow(() -> new ApplicationException(ErrorCode.ACCESS_DENIED));
        if (gv.getBoMon() == null) {
            throw new ApplicationException(ErrorCode.ACCESS_DENIED);
        }
        return gv.getBoMon().getId();
    }


}
