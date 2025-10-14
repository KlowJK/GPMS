package com.backend.gpms.features.progress.application;
import com.backend.gpms.common.exception.ApplicationException;
import com.backend.gpms.common.exception.ErrorCode;
import com.backend.gpms.common.mapper.BaoCaoMapper;
import com.backend.gpms.common.util.TimeGatekeeper;
import com.backend.gpms.features.defense.domain.ThoiGianThucHien;
import com.backend.gpms.features.lecturer.infra.GiangVienRepository;
import com.backend.gpms.features.outline.domain.DeCuong;
import com.backend.gpms.features.outline.domain.TrangThaiDuyetDon;
import com.backend.gpms.features.outline.infra.DeCuongRepository;
import com.backend.gpms.features.progress.domain.BaoCao;
import com.backend.gpms.features.progress.domain.TrangThaiNhatKy;
import com.backend.gpms.features.progress.dto.request.DuyetBaoCaoRequest;
import com.backend.gpms.features.progress.dto.response.BaoCaoResponse;
import com.backend.gpms.features.progress.infra.BaoCaoRepository;
import com.backend.gpms.features.storage.application.CloudinaryStorageService;
import com.backend.gpms.features.topic.domain.DeTai;
import com.backend.gpms.features.topic.domain.TrangThaiDeTai;
import com.backend.gpms.features.topic.infra.DeTaiRepository;
import jakarta.transaction.Transactional;
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

import java.time.*;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
@RequiredArgsConstructor
@Transactional
public class BaoCaoService {

    private static final Logger log = LoggerFactory.getLogger(NhatKyTienTrinhService.class);
    BaoCaoRepository baoCaoRepository;
    TimeGatekeeper timeGatekeeper;

    DeTaiRepository deTaiRepository;

    BaoCaoMapper baoCaoMapper;

    CloudinaryStorageService cloudinaryService;

    final GiangVienRepository giangVienRepository;

    LocalDateTime currentDate = LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh"));

    DeCuongRepository deCuongRepository;

    public List<BaoCaoResponse> getBaoCaoOfSinhVien() {
    String username = getCurrentUsername();

    List<BaoCao> list = baoCaoRepository.findByDeTai_SinhVien_User_EmailOrderByCreatedAt(username);

    return list.stream()
            .map(baoCaoMapper::toBaoCaoResponse)
            .collect(Collectors.toList());
    }

    public BaoCaoResponse nopBaoCao(MultipartFile request) {
        // Lấy username hiện tại
        String username = getCurrentUsername();

        // Kiểm tra thời gian nộp báo cáo
        ThoiGianThucHien thoiGianNopBaoCao = timeGatekeeper.validateThoiGianNopBaoCao();

        // Tìm đề tài của sinh viên
        DeTai deTai = deTaiRepository.findBySinhVien_User_EmailIgnoreCase(username)
                .orElseThrow(() -> new ApplicationException(ErrorCode.DE_TAI_NOT_FOUND));

        // Kiểm tra trạng thái đề tài
        if (deTai.getTrangThai() != TrangThaiDeTai.DA_DUYET) {
            throw new ApplicationException(ErrorCode.DE_TAI_NOT_APPROVED);
        }

        // Tìm đề cương mới nhất
        Optional<DeCuong> deC = deCuongRepository.findFirstByDeTai_IdOrderByUpdatedAtDesc(deTai.getId());
        if (deC.isEmpty()) {
            throw new ApplicationException(ErrorCode.DE_CUONG_NOT_FOUND);
        }

        DeCuong deCuong = deC.get();
        if (deCuong.getTbmDuyet() != TrangThaiDuyetDon.DA_DUYET) {
            throw new ApplicationException(ErrorCode.DE_CUONG_NOT_APPROVED);
        }

        // Tìm báo cáo cũ
        Optional<BaoCao> baoCaoOld = baoCaoRepository.findFirstByDeTai_SinhVien_User_EmailIgnoreCase(username);

        // Khởi tạo báo cáo mới
        BaoCao baoCao = new BaoCao();
        baoCao.setDeTai(deTai);
        baoCao.setGiangVienHuongDan(deTai.getGiangVienHuongDan());
        baoCao.setDiemHuongDan(null);

        // Xử lý file upload
        String fileUrl = null;
        if (request != null && !request.isEmpty()) {
            fileUrl = upload(request); // Giả định hàm upload trả về URL
            baoCao.setDuongDanFile(fileUrl);
        }

        // Xử lý phiên bản và giảng viên phản biện
        if (baoCaoOld.isEmpty()) {
            // Nếu chưa có báo cáo, tạo mới với phiên bản 1
            baoCao.setPhienBan(1);
        } else {
            BaoCao prev = baoCaoOld.get();

            if (prev.getTrangThai()==TrangThaiDuyetDon.DA_DUYET) {
                throw new ApplicationException(ErrorCode.BAO_CAO_ALREADY_APPROVED);
            }
            // Chỉ tạo báo cáo mới nếu báo cáo cũ bị từ chối
            if (prev.getTrangThai() == TrangThaiDuyetDon.TU_CHOI) { // Giả định có enum TrangThaiBaoCao
                baoCao.setPhienBan(prev.getPhienBan() + 1);
                // Lấy giảng viên phản biện từ báo cáo cũ (nếu có)
                baoCao.setGiangVienHuongDan(prev.getGiangVienHuongDan());
            } else {
                throw new ApplicationException(ErrorCode.BAO_CAO_NOT_REJECTED);
            }
        }

        // Lưu báo cáo
        baoCaoRepository.save(baoCao);

        // Trả về response
        return baoCaoMapper.toBaoCaoResponse(baoCao);
    }

    public List<BaoCaoResponse> getBaoCaoOfGiangVienList(TrangThaiDuyetDon trangThaiBaoCao) {
        String username = getCurrentUsername();

        // Tìm giảng viên theo email
        var giangVien = giangVienRepository.findByUser_EmailIgnoreCase(username)
                .orElseThrow(() -> new ApplicationException(ErrorCode.GIANG_VIEN_NOT_FOUND));

        List<BaoCao> list = (trangThaiBaoCao==null) ?
        baoCaoRepository.findByGiangVienHuongDan_IdOrderByCreatedAt(giangVien.getId()):
        baoCaoRepository.findByGiangVienHuongDan_IdAndTrangThaiOrderByCreatedAt(giangVien.getId(), trangThaiBaoCao);

        return list.stream()
                .map(baoCaoMapper::toBaoCaoResponse)
                .collect(Collectors.toList());
    }

    public Page<BaoCaoResponse> getBaoCaoOfGiangVienPage(TrangThaiDuyetDon trangThaiBaoCao, Pageable pageable) {
        String username = getCurrentUsername();

        // Tìm giảng viên theo email
        var giangVien = giangVienRepository.findByUser_EmailIgnoreCase(username)
                .orElseThrow(() -> new ApplicationException(ErrorCode.GIANG_VIEN_NOT_FOUND));

        Page<BaoCao> page = (trangThaiBaoCao==null) ?
                baoCaoRepository.findByGiangVienHuongDan_Id(giangVien.getId(), pageable):
                baoCaoRepository.findByGiangVienHuongDan_IdAndTrangThai(giangVien.getId(), trangThaiBaoCao, pageable);

        return page.map(baoCaoMapper::toBaoCaoResponse);
    }

    public BaoCaoResponse reviewBaoCao(DuyetBaoCaoRequest request, TrangThaiDuyetDon trangThai) {
        String username = getCurrentUsername();
        log.info("User {} is attempting to approve/reject report ID {}", username, request.getIdBaoCao());

        // Validate report ID
        if (request.getIdBaoCao() <= 0) {
            throw new ApplicationException(ErrorCode.INVALID_BAO_CAO_ID);
        }

        ThoiGianThucHien thoiGianNopBaoCao = timeGatekeeper.validateThoiGianNopBaoCao();

        // Find lecturer by email
        var giangVien = giangVienRepository.findByUser_EmailIgnoreCase(username)
                .orElseThrow(() -> new ApplicationException(ErrorCode.GIANG_VIEN_NOT_FOUND));

        // Find report by ID
        BaoCao baoCao = baoCaoRepository.findById(request.getIdBaoCao())
                .orElseThrow(() -> new ApplicationException(ErrorCode.BAO_CAO_NOT_FOUND));

        // Check authorization
        if (!baoCao.getGiangVienHuongDan().getId().equals(giangVien.getId())) {
            throw new ApplicationException(ErrorCode.FORBIDDEN);
        }

        // Check if report is already approved
        if (baoCao.getTrangThai() == TrangThaiDuyetDon.DA_DUYET) {
            throw new ApplicationException(ErrorCode.BAO_CAO_ALREADY_APPROVED);
        }

        if (baoCao.getTrangThai() == TrangThaiDuyetDon.TU_CHOI) {
            throw new ApplicationException(ErrorCode.BAO_CAO_ALREADY_REJECTED);
        }
        // Handle rejection
        if (trangThai == TrangThaiDuyetDon.TU_CHOI) {
            if (request.getNhanXet() == null || request.getNhanXet().isBlank()) {
                throw new ApplicationException(ErrorCode.REVIEW_REQUIRED_FOR_REJECTION);
            }
            baoCao.setGhiChu(request.getNhanXet());
        }

        // Handle approval
        if (trangThai == TrangThaiDuyetDon.DA_DUYET) {

            if (request.getDiemHuongDan() == null) {
                throw new ApplicationException(ErrorCode.SCORE_REQUIRED_FOR_APPROVAL);
            }
            if (request.getDiemHuongDan() < 0 || request.getDiemHuongDan() > 10) {
                throw new ApplicationException(ErrorCode.INVALID_SCORE_RANGE);
            }
            baoCao.setDiemHuongDan(request.getDiemHuongDan());
            baoCao.setGhiChu(request.getNhanXet());
        }

        // Update report status
        baoCao.setTrangThai(trangThai);
        baoCaoRepository.save(baoCao);

        log.info("Report ID {} updated with status {}", request.getIdBaoCao(), trangThai);
        return baoCaoMapper.toBaoCaoResponse(baoCao);
    }

    public BaoCaoResponse duyetBaoCao(DuyetBaoCaoRequest request) {
        return reviewBaoCao(request, TrangThaiDuyetDon.DA_DUYET);
    }

    public BaoCaoResponse tuChoiBaoCao(DuyetBaoCaoRequest request) {
        return reviewBaoCao(request, TrangThaiDuyetDon.TU_CHOI);
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

