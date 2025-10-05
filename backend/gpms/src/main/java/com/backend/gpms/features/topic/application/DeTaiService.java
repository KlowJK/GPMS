package com.backend.gpms.features.topic.application;

import com.backend.gpms.common.exception.ApplicationException;
import com.backend.gpms.common.exception.ErrorCode;
import com.backend.gpms.common.mapper.DeTaiMapper;
import com.backend.gpms.features.defense.domain.DotBaoVe;
import com.backend.gpms.features.defense.domain.ThoiGianThucHien;
import com.backend.gpms.features.lecturer.domain.GiangVien;
import com.backend.gpms.features.lecturer.infra.GiangVienRepository;
import com.backend.gpms.features.storage.application.CloudinaryStorageService;
import com.backend.gpms.features.student.domain.SinhVien;
import com.backend.gpms.features.student.infra.SinhVienRepository;
import com.backend.gpms.features.topic.domain.DeTai;
import com.backend.gpms.features.topic.dto.request.DeTaiApprovalRequest;
import com.backend.gpms.features.topic.dto.request.DeTaiGiangVienHuongDanRequest;
import com.backend.gpms.features.topic.dto.request.DeTaiRequest;
import com.backend.gpms.features.topic.dto.response.DeTaiResponse;
import com.backend.gpms.features.topic.dto.response.DeTaiGiangVienHuongDanResponse;
import com.backend.gpms.features.topic.infra.DeTaiRepository;
import com.backend.gpms.common.util.TimeGatekeeper;
import com.backend.gpms.features.topic.domain.TrangThaiDeTai;
import org.springframework.security.core.Authentication;

import jakarta.transaction.Transactional;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.multipart.MultipartFile;

import java.util.Optional;

@Service
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
@RequiredArgsConstructor
@Transactional
public class DeTaiService {
    private static final Logger log = LoggerFactory.getLogger(DeTaiService.class);
    DeTaiRepository deTaiRepository;
    SinhVienRepository sinhVienRepository;
    GiangVienRepository giangVienRepository;
    CloudinaryStorageService cloudinaryService;
    DeTaiMapper deTaiMapper;
    TimeGatekeeper timeGatekeeper;

    public DeTaiResponse approveByGiangVien(Long deTaiId, String nhanXet) {
        DeTaiApprovalRequest req = new DeTaiApprovalRequest(true, nhanXet);
        return approveDeTai(deTaiId, req);
    }

    public DeTaiResponse rejectByGiangVien(Long deTaiId, String nhanXet){
        DeTaiApprovalRequest req = new DeTaiApprovalRequest(false, nhanXet);
        return approveDeTai(deTaiId, req);
    };

    public DeTaiResponse registerDeTai(DeTaiRequest request){
        // get sinh viên
        String accountEmail = getCurrentUsername();
        SinhVien sv = sinhVienRepository.findByUser_Email(accountEmail)
                .orElseThrow(() -> new ApplicationException(ErrorCode.SINH_VIEN_NOT_FOUND));
        ThoiGianThucHien thoiGianDangKy = timeGatekeeper.validateThoiGianDangKy();
        DotBaoVe dotBaoVe = thoiGianDangKy.getDotBaoVe();
        DeTai deTai = sv.getDeTai();
        GiangVien gv = giangVienRepository.findById(request.getGvhdId())
                .orElseThrow(() -> new ApplicationException(ErrorCode.GIANG_VIEN_NOT_FOUND));
        if (deTai == null) {
            deTai = deTaiMapper.toDeTai(request);
            deTai.setSinhVien(sv);
        } else {
            if(deTai.getTrangThai() == TrangThaiDeTai.DA_DUYET){
                throw  new ApplicationException(ErrorCode.DE_TAI_ALREADY_ACCEPTED);
            }
            deTaiMapper.update(request, deTai);
        }

        deTai.setBoMon(gv.getBoMon());

        deTai.setTrangThai(TrangThaiDeTai.CHO_DUYET);

        if (request.getFileTongQuan() != null && !request.getFileTongQuan().isEmpty()) {
            String url = upload(request.getFileTongQuan());
            deTai.setNoiDungDeTaiUrl(url);
        }

        deTai.setDotBaoVe(dotBaoVe);
        DeTai saved = deTaiRepository.save(deTai);
        return deTaiMapper.toDeTaiResponse(saved);
    };

    public DeTaiResponse getMyDeTai(){
        String accountEmail = getCurrentUsername();
        SinhVien sv = sinhVienRepository.findByUser_Email(accountEmail)
                .orElseThrow(() -> new ApplicationException(ErrorCode.SINH_VIEN_NOT_FOUND));

        DeTai deTai = deTaiRepository.findDeTaiBySinhVien_Id(sv.getId())
                .orElseThrow(() -> new ApplicationException(ErrorCode.DE_TAI_NOT_FOUND));

        return deTaiMapper.toDeTaiResponse(deTai);
    };

    public DeTaiGiangVienHuongDanResponse addGiangVienHuongDan(DeTaiGiangVienHuongDanRequest request){
        SinhVien sv = sinhVienRepository.findByMaSinhVien(request.getMaSV())
                .orElseThrow(() -> new ApplicationException(ErrorCode.SINH_VIEN_NOT_FOUND));
        GiangVien gv = giangVienRepository.findByMaGiangVien(request.getMaGV()).
                orElseThrow(() -> new ApplicationException(ErrorCode.GIANG_VIEN_NOT_FOUND));
        Optional<DeTai> deTai = deTaiRepository.findDeTaiBySinhVien_Id(sv.getId());
        if(deTai.isPresent()) {
            throw new ApplicationException(ErrorCode.SINH_VIEN_ALREADY_REGISTERED_DE_TAI);
        }
        DeTai newDeTai = DeTai.builder()
                .sinhVien(sv)
                .giangVienHuongDan(gv)
                .build();
        deTaiRepository.save(newDeTai);
        return DeTaiGiangVienHuongDanResponse.builder()
                .success(true)
                .message("Gán đề tài và giảng viên hướng dẫn thành công.")
                .build();
    };

    public Page<DeTaiResponse> getDeTaiByLecturerAndStatus(TrangThaiDeTai trangThai, Pageable pageable){
        String email = getCurrentUsername();
        GiangVien gv = giangVienRepository.findByUser_Email((email))
                .orElseThrow(() -> new ApplicationException(ErrorCode.NOT_GVHD_OF_DE_TAI));
        Long gvhdId = gv.getId();

        var page = deTaiRepository.findByGiangVienHuongDan_IdAndTrangThai(gvhdId, trangThai, pageable);
        return page.map(deTaiMapper::toDeTaiResponse);
    };

    public DeTaiResponse approveDeTai(Long deTaiId, DeTaiApprovalRequest request){
        // 1) load đề tài
        DeTai detai = deTaiRepository.findById(deTaiId)
                .orElseThrow(() -> new ApplicationException(ErrorCode.DE_TAI_NOT_FOUND));

        String email = getCurrentUsername();
        GiangVien gv = giangVienRepository.findByUser_Email((email))
                .orElseThrow(() -> new ApplicationException(ErrorCode.NOT_GVHD_OF_DE_TAI));
        Long gvhdId = gv.getId();

        // 2) xác thực đúng GVHD
        if (detai.getGiangVienHuongDan() == null || !gvhdId.equals(detai.getGiangVienHuongDan().getId())) {
            throw new ApplicationException(ErrorCode.NOT_GVHD_OF_DE_TAI);
        }

        // 3) chỉ cho duyệt khi đang PENDING
        if (detai.getTrangThai() != TrangThaiDeTai.CHO_DUYET) {
            throw new ApplicationException(ErrorCode.DE_TAI_NOT_IN_PENDING_STATUS);
        }

        // 4) chuyển trạng thái + lưu nhận xét
        if (Boolean.TRUE.equals(request.getApproved())) {
            detai.setTrangThai(TrangThaiDeTai.DA_DUYET);
        } else if (Boolean.FALSE.equals(request.getApproved())) {
            detai.setTrangThai(TrangThaiDeTai.TU_CHOI);
        } else {
            throw new ApplicationException(ErrorCode.TRANG_THAI_INVALID);
        }
        detai.setNhanXet(request.getNhanXet());
        return deTaiMapper.toDeTaiResponse(deTaiRepository.save(detai));
    };


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