package com.backend.gpms.features.topic.application;

import com.backend.gpms.common.exception.ApplicationException;
import com.backend.gpms.common.exception.ErrorCode;
import com.backend.gpms.common.mapper.DonHoanDoAnMapper;
import com.backend.gpms.features.department.domain.Khoa;
import com.backend.gpms.features.department.domain.Nganh;
import com.backend.gpms.features.department.infra.KhoaRepository;
import com.backend.gpms.features.lecturer.domain.GiangVien;
import com.backend.gpms.features.lecturer.infra.GiangVienRepository;
import com.backend.gpms.features.storage.application.StorageService;
import com.backend.gpms.features.student.domain.SinhVien;
import com.backend.gpms.features.student.infra.SinhVienRepository;
import com.backend.gpms.features.topic.domain.DonHoanDoAn;
import com.backend.gpms.features.topic.domain.TrangThaiDeTai;
import com.backend.gpms.features.topic.dto.request.DonHoanDoAnDuyetRequest;
import com.backend.gpms.features.topic.dto.request.DonHoanDoAnRequest;
import com.backend.gpms.features.topic.dto.response.DonHoanDoAnResponse;
import com.backend.gpms.features.topic.infra.DonHoanDoAnRepository;
import jakarta.transaction.Transactional;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@Transactional
@RestController
public class DonHoanDoAnService {

    DonHoanDoAnRepository donHoanDoAnRepository;
    SinhVienRepository sinhVienRepository;
    DonHoanDoAnMapper donHoanDoAnMapper;
    StorageService cloudinaryService; // đã có trong dự án của bạn
    GiangVienRepository giangVienRepository;
    KhoaRepository khoaRepository;

    private static final long MAX_PDF_BYTES = 10 * 1024 * 1024; // 10MB


    public DonHoanDoAnResponse createPostponeRequest(DonHoanDoAnRequest request) {
        SinhVien sv = getCurrentSinhVienOrThrow();

        assertEligibleNoDeTai(sv);
        assertNoPendingRequest(sv.getId());

        DonHoanDoAn don = buildDraftDonHoanDoAn(sv, request.getLyDo());

        // ---- dùng helper: chỉ khi có file minh chứng ----
        if (hasFile(request.getMinhChungFile())) {
            String pdfUrl = uploadMinhChungAsPdfOrThrow(request.getMinhChungFile());
            don.setMinhChungUrl(pdfUrl);               // URL raw -> thường .pdf
            // Nếu có field contentType: don.setMinhChungContentType("application/pdf");
        }

        return donHoanDoAnMapper.toResponse(donHoanDoAnRepository.save(don));
    }

    // ================== Helpers (PRIVATE) ==================

    private boolean hasFile(MultipartFile f) {
        return f != null && !f.isEmpty();
    }

    /** Validate & upload file PDF ở dạng RAW để URL ra .pdf */
    private String uploadMinhChungAsPdfOrThrow(MultipartFile file) {
        validatePdf(file);
        try {
            return cloudinaryService.uploadRawFile(file); // đã set resource_type=raw trong service của bạn
        } catch (Exception e) {
            throw new ApplicationException(ErrorCode.DON_HOAN_FILE_UPLOAD_FAILED);
        }
    }

    /** Chỉ chấp nhận PDF, kiểm tra MIME + magic bytes + size */
    private void validatePdf(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new ApplicationException(ErrorCode.FILE_EMPTY);
        }
        String ct = file.getContentType();
        boolean mimeOk = "application/pdf".equalsIgnoreCase(ct);
        boolean magicOk = looksLikePdf(file); // %PDF

        if (!(mimeOk || magicOk)) {
            throw new ApplicationException(ErrorCode.FILE_TYPE_NOT_ALLOWED);
        }
        if (file.getSize() > MAX_PDF_BYTES) {
            throw new ApplicationException(ErrorCode.FILE_TOO_LARGE);
        }
    }

    private boolean looksLikePdf(MultipartFile file) {
        try (var is = file.getInputStream()) {
            byte[] header = is.readNBytes(4);
            return header.length == 4
                    && header[0] == 0x25 // '%'
                    && header[1] == 0x50 // 'P'
                    && header[2] == 0x44 // 'D'
                    && header[3] == 0x46; // 'F'
        } catch (Exception e) {
            return false;
        }
    }

    private SinhVien getCurrentSinhVienOrThrow() {
        var auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || auth.getName() == null) {
            throw new ApplicationException(ErrorCode.UNAUTHENTICATED);
        }
        String email = auth.getName();
        return sinhVienRepository.findByUser_Email(email)
                .orElseThrow(() -> new ApplicationException(ErrorCode.SINH_VIEN_NOT_FOUND));
    }

    private void assertEligibleNoDeTai(SinhVien sv) {
        if (sv.getDeTai() != null) {
            throw new ApplicationException(ErrorCode.POSTPONE_NOT_ALLOWED_WHEN_HAS_DE_TAI);
        }
    }

    private void assertNoPendingRequest(Long sinhVienId) {
        if (donHoanDoAnRepository.existsBySinhVien_IdAndTrangThai(sinhVienId, TrangThaiDeTai.CHO_DUYET)) {
            throw new ApplicationException(ErrorCode.DON_HOAN_ALREADY_PENDING);
        }
    }

    private DonHoanDoAn buildDraftDonHoanDoAn(SinhVien sv, String lyDo) {
        DonHoanDoAn don = new DonHoanDoAn();
        don.setSinhVien(sv);
        don.setTrangThai(TrangThaiDeTai.CHO_DUYET);
        don.setLyDo(lyDo);
        don.setCreatedAt(LocalDateTime.now());
        return don;
    }


    public Page<DonHoanDoAnResponse> getMyPostponeRequests(Pageable pageable) {
        String email = currentEmail();

        SinhVien sv = sinhVienRepository.findByUser_Email(email)
                .orElseThrow(() -> new ApplicationException(ErrorCode.SINH_VIEN_NOT_FOUND));

        return donHoanDoAnRepository.findBySinhVien_Id(sv.getId(), pageable)
                .map(donHoanDoAnMapper::toResponse);
    }

    public Page<DonHoanDoAnResponse> getMyPostponeRequestsByCNKHOA(Pageable pageable) {
        String email = currentEmail();

        // Lấy giảng viên theo email
        GiangVien chuNhiemKhoa = giangVienRepository.findByUser_Email(email)
                .orElseThrow(() -> new ApplicationException(ErrorCode.GIANG_VIEN_NOT_FOUND));

        Khoa khoa = khoaRepository.findByChuNhiemKhoa_Id(chuNhiemKhoa.getId())
                .orElseThrow(() -> new ApplicationException(ErrorCode.KHOA_NOT_FOUND));
        // Lấy khoa mà giảng viên này đang làm chủ nhiệm
        if (khoa == null) {
            return Page.empty(pageable); // Không có khoa → trả về trang rỗng
        }

        // Lấy tất cả đơn hoãn đồ án của sinh viên thuộc khoa này
        return donHoanDoAnRepository.findBySinhVien_Lop_Nganh_Khoa(khoa, pageable)
                .map(donHoanDoAnMapper::toResponse);
    }

    public String duyetDonHoanDoAn(DonHoanDoAnDuyetRequest request) {
        String email = currentEmail();

        // 1. Lấy giảng viên (CNKHOA) đang đăng nhập
        GiangVien chuNhiemKhoa = giangVienRepository.findByUser_Email(email)
                .orElseThrow(() -> new ApplicationException(ErrorCode.GIANG_VIEN_NOT_FOUND));

        // 2. Lấy đơn hoãn đồ án
        DonHoanDoAn don = donHoanDoAnRepository.findById(request.getDonHoanDoAnId())
                .orElseThrow(() -> new ApplicationException(ErrorCode.DON_NOT_FOUND));

        // 3. Kiểm tra trạng thái hiện tại
        if (don.getTrangThai() != TrangThaiDeTai.CHO_DUYET) {
            throw new ApplicationException(ErrorCode.DON_DA_XU_LY);
        }

        // 4. Kiểm tra sinh viên có thuộc khoa do giảng viên này chủ nhiệm không
        SinhVien sinhVien = don.getSinhVien();
        Nganh nganh = sinhVien.getLop().getNganh();
        Khoa khoaCuaSinhVien = nganh.getKhoa();

        Khoa khoaChuNhiem = khoaRepository.findByChuNhiemKhoa_Id(chuNhiemKhoa.getId())
                .orElseThrow(() -> new ApplicationException(ErrorCode.KHOA_NOT_FOUND));

        if (!khoaChuNhiem.getId().equals(khoaCuaSinhVien.getId())) {
            throw new ApplicationException(ErrorCode.KHONG_CO_QUYEN_PHE_DUYET);
        }

        if (hasFile(request.getBienbanHopPheDuyetFile())) {
            String pdfUrl = uploadMinhChungAsPdfOrThrow(request.getBienbanHopPheDuyetFile());
            don.setGhiChuQuyetDinh(pdfUrl);

        }
        // 5. Cập nhật trạng thái + ghi chú + người duyệt
        don.setTrangThai(TrangThaiDeTai.DA_DUYET);

        don.setNguoiPheDuyet(chuNhiemKhoa.getUser()); // User hiện tại

        donHoanDoAnRepository.save(don);

        return "Đơn hoãn đồ án đã được duyệt thành công.";
    }


    private String currentEmail() {
        var auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || auth.getName() == null) {
            throw new ApplicationException(ErrorCode.UNAUTHENTICATED);
        }
        return auth.getName(); // hệ thống của bạn đang set email làm username
    }
}

