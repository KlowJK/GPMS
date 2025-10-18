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
import java.util.Objects;
import java.util.Optional;
import java.util.function.Function;
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
        final String email = currentUsername();

        DeTai deTai = deTaiRepository
                .findBySinhVien_User_EmailIgnoreCase(email)
                .orElseThrow(() -> new ApplicationException(ErrorCode.DE_TAI_NOT_FOUND));

        if (deTai.getTrangThai() != TrangThaiDeTai.DA_DUYET) {
            throw new ApplicationException(ErrorCode.DE_TAI_NOT_ACCEPTED);
        }
        if (deTai.getDotBaoVe() == null) {
            throw new ApplicationException(ErrorCode.NO_ACTIVE_SUBMISSION_WINDOW);
        }

        timeGatekeeper.assertWithinWindow(CongViec.NOP_DE_CUONG, deTai.getDotBaoVe());

        final String finalUrl = toClickableUrl(request.getFileUrl());
        if (finalUrl == null || finalUrl.isBlank()) {
            throw new ApplicationException(ErrorCode.FILE_URL_EMPTY);
        }

        // Lấy phiên bản mới nhất
        Optional<DeCuong> latestOpt =
                deCuongRepository.findFirstByDeTai_SinhVien_User_EmailIgnoreCaseOrderByCreatedAtDesc(email);

        // Helper: tạo phiên bản mới dựa trên phiên bản cũ (nếu có)
        Function<DeCuong, DeCuong> newVersionFrom = (prev) -> {
            DeCuong n = new DeCuong();
            n.setDeTai(deTai);
            n.setDuongDanFile(finalUrl);
            n.setGiangVienHuongDan(deTai.getGiangVienHuongDan());
            n.setPhienBan(prev == null ? 1 : prev.getPhienBan() + 1);

            // GVPB: lấy từ prev nếu có, nếu chưa thì rơi về DeTai (nếu đã phân công)
            var gvpb = (prev != null && prev.getGiangVienPhanBien() != null)
                    ? prev.getGiangVienPhanBien()
                    : null; // cần có field này ở DeTai
            n.setGiangVienPhanBien(gvpb);

            // TBM: lấy từ bộ môn của đề tài (null-safe)
            var boMon = deTai.getBoMon();
            if (boMon == null || boMon.getTruongBoMon() == null) {
                throw new ApplicationException(ErrorCode.BO_MON_OR_TBM_NOT_ASSIGNED);
            }
            n.setTruongBoMon(boMon.getTruongBoMon());

            return n;
        };


        DeCuong newVer;

        if (latestOpt.isEmpty()) {
            // Chưa từng nộp → bắt đầu ở bước GVHD
            newVer = newVersionFrom.apply(null);
            newVer.setTrangThaiDeCuong(TrangThaiDeCuong.CHO_DUYET);
            newVer.setGvPhanBienDuyet(null);
            newVer.setTbmDuyet(null);
        } else {
            DeCuong prev = latestOpt.get();

            // Nếu đã duyệt hoàn tất (GVHD duyệt + GVPB duyệt + TBM duyệt) → chặn nộp
            boolean fullyApproved =
                    prev.getTrangThaiDeCuong() == TrangThaiDeCuong.DA_DUYET
                            && prev.getGvPhanBienDuyet() == TrangThaiDuyetDon.DA_DUYET
                            && prev.getTbmDuyet() == TrangThaiDuyetDon.DA_DUYET;

            if (fullyApproved) {
                throw new ApplicationException(ErrorCode.DE_CUONG_FULLY_APPROVED);
            }

            newVer = newVersionFrom.apply(prev);

            if (prev.getTrangThaiDeCuong() == TrangThaiDeCuong.TU_CHOI
                    || prev.getTrangThaiDeCuong() == TrangThaiDeCuong.CHO_DUYET) {
                // Bị từ chối (GVHD) hoặc đang chờ GVHD mà SV muốn nộp lại → quay về bước GVHD
                newVer.setTrangThaiDeCuong(TrangThaiDeCuong.CHO_DUYET);
                newVer.setGvPhanBienDuyet(null);
                newVer.setTbmDuyet(null);
            } else if (prev.getTrangThaiDeCuong() == TrangThaiDeCuong.DA_DUYET) {
                // Qua được GVHD rồi
                if (prev.getGvPhanBienDuyet() == TrangThaiDuyetDon.DA_DUYET) {
                    // Qua được GVPB rồi → tới TBM
                    if (prev.getTbmDuyet() == TrangThaiDuyetDon.DA_DUYET) {
                        // Trường hợp này đã fullyApproved ở trên; tới đây là còn TU_CHOI/CHO_DUYET hoặc null
                    }
                    newVer.setTrangThaiDeCuong(TrangThaiDeCuong.DA_DUYET);       // giữ kết quả GVHD
                    newVer.setGvPhanBienDuyet(TrangThaiDuyetDon.DA_DUYET);       // giữ kết quả GVPB
                    newVer.setTbmDuyet(TrangThaiDuyetDon.CHO_DUYET);             // yêu cầu TBM duyệt lại
                } else {
                    // Chưa qua GVPB (null/CHO_DUYET/TU_CHOI) → đưa về chờ GVPB
                    newVer.setTrangThaiDeCuong(TrangThaiDeCuong.DA_DUYET);       // giữ kết quả GVHD
                    newVer.setGvPhanBienDuyet(TrangThaiDuyetDon.CHO_DUYET);      // yêu cầu GVPB duyệt lại
                    newVer.setTbmDuyet(null);                                    // TBM sẽ tới sau
                }
            } else {
                // Phòng hờ trạng thái lạ → quay về bước GVHD
                newVer.setTrangThaiDeCuong(TrangThaiDeCuong.CHO_DUYET);
                newVer.setGvPhanBienDuyet(null);
                newVer.setTbmDuyet(null);
            }
        }

        return mapper.toResponse(deCuongRepository.save(newVer));
    }




    public List<DeCuongNhanXetResponse> viewDeCuongLog() {
        String email = currentUsername();
        List<DeCuong> deCuongs = deCuongRepository.findByDeTai_SinhVien_User_EmailIgnoreCaseOrderByPhienBanDesc(email);
        if (deCuongs.isEmpty()) throw new ApplicationException(ErrorCode.DE_CUONG_NOT_FOUND);

        // Lấy trước toàn bộ nhận xét của các đề cương liên quan (tránh N+1)
        List<Long> ids = deCuongs.stream().map(DeCuong::getId).toList();
        List<NhanXetDeCuong> allComments = deCuongLogRepository.findByDeCuong_IdInOrderByCreatedAtDesc(ids);
        Map<Long, List<NhanXetDeCuong>> commentsByDeCuongId = allComments.stream().collect(Collectors.groupingBy(c -> c.getDeCuong().getId()));
        List<DeCuongNhanXetResponse> responses = mapper.toDeCuongNhanXetResponse(deCuongs);
        for (DeCuongNhanXetResponse res : responses) {
            List<NhanXetDeCuong> cList = commentsByDeCuongId.getOrDefault(res.getId(), List.of());
            res.setNhanXets(mapper.toNhanXetDeCuongResponse(cList));
        }
        return responses;
    }


    public DeCuongResponse reviewDeCuong(Long deCuongId, boolean approve, String reason) {
        final String email = currentUsername();

        final GiangVien gv = giangVienRepository.findByUser_EmailIgnoreCase(email)
                .orElseThrow(() -> new ApplicationException(ErrorCode.GIANG_VIEN_NOT_FOUND));

        final DeCuong dc = deCuongRepository.findById(deCuongId)
                .orElseThrow(() -> new ApplicationException(ErrorCode.DE_CUONG_NOT_FOUND));

        final DeTai deTai = dc.getDeTai();
        if (deTai == null || deTai.getDotBaoVe() == null) {
            throw new ApplicationException(ErrorCode.NO_ACTIVE_SUBMISSION_WINDOW);
        }

        final var currentDot = timeGatekeeper.getCurrentDotBaoVe();
        if (currentDot == null || !Objects.equals(currentDot.getId(), deTai.getDotBaoVe().getId())) {
            throw new ApplicationException(ErrorCode.NOT_IN_DOT_BAO_VE);
        }

        // Chuẩn hóa reason
        final String normalizedReason = reason == null ? "" : reason.trim();

        // Helper ghi log
        Runnable logApprove = () -> {
            var log = new NhanXetDeCuong();
            log.setDeCuong(dc);
            log.setNhanXet(normalizedReason);
            log.setGiangVien(gv);
            deCuongLogRepository.save(log);
        };

        // Xác định vai trò theo mối quan hệ trong đề cương (null-safe)
        final Long gvId = gv.getId();
        final Long gvhdId = dc.getGiangVienHuongDan() != null ? dc.getGiangVienHuongDan().getId() : null;
        final Long gvpbId = dc.getGiangVienPhanBien() != null ? dc.getGiangVienPhanBien().getId() : null;
        final Long tbmId  = dc.getTruongBoMon() != null ? dc.getTruongBoMon().getId() : null;

        boolean acted = false;

        // 1) GVHD duyệt trạng thái đề cương
        if (Objects.equals(gvId, gvhdId)) {
            if (dc.getTrangThaiDeCuong() == TrangThaiDeCuong.DA_DUYET)
                throw new ApplicationException(ErrorCode.DE_CUONG_ALREADY_APPROVED);
            if (dc.getTrangThaiDeCuong() == TrangThaiDeCuong.TU_CHOI)
                throw new ApplicationException(ErrorCode.DE_CUONG_ALREADY_REJECTED);
            if (dc.getTrangThaiDeCuong() != TrangThaiDeCuong.CHO_DUYET)
                throw new ApplicationException(ErrorCode.DE_CUONG_NOT_PENDING);

            if (approve) {
                dc.setTrangThaiDeCuong(TrangThaiDeCuong.DA_DUYET);
                dc.setGvPhanBienDuyet(TrangThaiDuyetDon.CHO_DUYET);
                logApprove.run();
            } else {
                if (normalizedReason.isBlank())
                    throw new ApplicationException(ErrorCode.DE_CUONG_REASON_REQUIRED);
                logApprove.run();
                dc.setTrangThaiDeCuong(TrangThaiDeCuong.TU_CHOI);
            }
            acted = true;
        }

        // 2) GVPB duyệt cờ phản biện (chỉ sau khi GVHD đã duyệt)
        else if (Objects.equals(gvId, gvpbId)) {
            if (dc.getTrangThaiDeCuong() != TrangThaiDeCuong.DA_DUYET)
                throw new ApplicationException(ErrorCode.DE_CUONG_NOT_APPROVED_BY_GVHD);

            if(dc.getGvPhanBienDuyet()==TrangThaiDuyetDon.DA_DUYET)
                throw new ApplicationException(ErrorCode.DE_CUONG_ALREADY_APPROVED);

            if (approve) {
                dc.setGvPhanBienDuyet(TrangThaiDuyetDon.DA_DUYET);
                dc.setTbmDuyet(TrangThaiDuyetDon.CHO_DUYET);
                logApprove.run();
            } else {
                if (normalizedReason.isBlank())
                    throw new ApplicationException(ErrorCode.DE_CUONG_REASON_REQUIRED);
                logApprove.run();
                dc.setGvPhanBienDuyet(TrangThaiDuyetDon.TU_CHOI);

                // Nếu nghiệp vụ muốn tổng thể bị từ chối, mở comment dòng sau:
                // dc.setTrangThaiDeCuong(TrangThaiDeCuong.TU_CHOI);
            }
            acted = true;
        }

        // 3) TBM duyệt cờ trưởng bộ môn (sau khi GVPB đã duyệt)
        else if (Objects.equals(gvId, tbmId)) {
            if (dc.getTrangThaiDeCuong() != TrangThaiDeCuong.DA_DUYET)
                throw new ApplicationException(ErrorCode.DE_CUONG_NOT_APPROVED_BY_GVHD);
            if (dc.getGvPhanBienDuyet() != TrangThaiDuyetDon.DA_DUYET)
                throw new ApplicationException(ErrorCode.DE_CUONG_NOT_APPROVED_BY_GVPB);
            if(dc.getTbmDuyet()==TrangThaiDuyetDon.DA_DUYET)
                throw new ApplicationException(ErrorCode.DE_CUONG_ALREADY_APPROVED);

            if (approve) {
                dc.setTbmDuyet(TrangThaiDuyetDon.DA_DUYET);
                logApprove.run();
            } else {
                if (normalizedReason.isBlank())
                    throw new ApplicationException(ErrorCode.DE_CUONG_REASON_REQUIRED);
                logApprove.run();
                dc.setTbmDuyet(TrangThaiDuyetDon.TU_CHOI);

                // Nếu muốn tổng thể bị từ chối:
                // dc.setTrangThaiDeCuong(TrangThaiDeCuong.TU_CHOI);
            }
            acted = true;
        }

        if (!acted) {
            throw new ApplicationException(ErrorCode.GIANG_VIEN_NOT_FOUND);
        }

        // Luôn save và trả response ở một chỗ
        DeCuong saved = deCuongRepository.save(dc);
        return mapper.toResponse(saved);
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
                    .findOutlinesForUserByRoleAndStatus(
                            email, activeDotIds, status, statusFilter, statusFilter, pageable)
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
                .orElseThrow(() -> new ApplicationException(ErrorCode.GIANG_VIEN_NOT_FOUND));
        if (gv.getBoMon() == null) {
            throw new ApplicationException(ErrorCode.BO_MON_OR_TBM_NOT_ASSIGNED);
        }
        return gv.getBoMon().getId();
    }


}
