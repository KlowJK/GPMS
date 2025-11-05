package com.backend.gpms.features.lecturer.application;

import com.backend.gpms.common.exception.ApplicationException;
import com.backend.gpms.common.exception.ErrorCode;
import com.backend.gpms.common.mapper.DeCuongMapper;
import com.backend.gpms.common.mapper.GiangVienMapper;
import com.backend.gpms.common.mapper.SinhVienMapper;
import com.backend.gpms.common.util.TimeGatekeeper;
import com.backend.gpms.features.auth.domain.Role;
import com.backend.gpms.features.auth.domain.User;
import com.backend.gpms.features.auth.infra.UserRepository;
import com.backend.gpms.features.defense.domain.DotBaoVe;
import com.backend.gpms.features.department.domain.BoMon;
import com.backend.gpms.features.department.domain.Khoa;
import com.backend.gpms.features.department.domain.Nganh;
import com.backend.gpms.features.department.infra.BoMonRepository;
import com.backend.gpms.features.department.infra.NganhRepository;
import com.backend.gpms.features.lecturer.domain.GiangVien;
import com.backend.gpms.features.lecturer.dto.request.GiangVienCreationRequest;
import com.backend.gpms.features.lecturer.dto.request.GiangVienUpdateRequest;
import com.backend.gpms.features.lecturer.dto.request.TroLyKhoaCreationRequest;
import com.backend.gpms.features.lecturer.dto.response.*;
import com.backend.gpms.features.lecturer.infra.GiangVienLoad;
import com.backend.gpms.features.lecturer.infra.GiangVienRepository;
import com.backend.gpms.features.outline.domain.DeCuong;
import com.backend.gpms.features.outline.domain.NhanXetDeCuong;
import com.backend.gpms.features.outline.dto.response.DeCuongNhanXetResponse;
import com.backend.gpms.features.outline.infra.DeCuongRepository;
import com.backend.gpms.features.outline.infra.NhanXetDeCuongRepository;
import com.backend.gpms.features.progress.application.NhatKyTienTrinhService;
import com.backend.gpms.features.student.domain.SinhVien;
import com.backend.gpms.features.student.domain.SinhVienSpecification;
import com.backend.gpms.features.student.infra.SinhVienRepository;
import com.backend.gpms.features.topic.domain.TrangThaiDeTai;
import com.backend.gpms.features.topic.infra.DeTaiRepository;
import jakarta.transaction.Transactional;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.io.InputStream;
import java.util.*;
import java.util.stream.Collectors;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.multipart.MultipartFile;

@Service
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
@RequiredArgsConstructor
@Transactional
public class GiangVienService {

    BoMonRepository boMonRepository;
    GiangVienRepository giangVienRepository;
    DeTaiRepository deTaiRepository;
    NganhRepository nganhRepository;
    UserRepository taiKhoanRepository;
    PasswordEncoder passwordEncoder;
    GiangVienMapper giangVienMapper;
    SinhVienRepository sinhVienRepository;
    SinhVienMapper sinhVienMapper;
    TimeGatekeeper timeGatekeeper;
    DeCuongRepository deCuongRepository;
    DeCuongMapper deCuongMapper;
    NhanXetDeCuongRepository deCuongLogRepository;
    NhatKyTienTrinhService nhatKyTienTrinhService;


    public List<GiangVienLiteResponse> giangVienLiteResponseList() {
        final String email = getCurrentUsername();

        SinhVien sv = sinhVienRepository.findByUser_Email(email)
                .orElseThrow(() -> new ApplicationException(ErrorCode.SINH_VIEN_NOT_FOUND));

        if (sv.getLop() == null) return List.of();

        Long khoaId = nganhRepository.findById(sv.getLop().getNganh().getId())
                .orElseThrow(() -> new ApplicationException(ErrorCode.NGANH_NOT_FOUND))
                .getKhoa()
                .getId();

        // 1 query ra đúng dữ liệu đã tính toán + sắp xếp
        List<GiangVienLiteProjection> rows = giangVienRepository
                .findAdvisorsWithRemainingByKhoaId(khoaId, TrangThaiDeTai.DA_DUYET);

        // Nếu muốn trả đúng class response (không phải projection), map nhẹ:
        return rows.stream()
                .map(r -> GiangVienLiteResponse.builder()
                        .id(r.getId())
                        .hoTen(r.getHoTen())
                        .boMonId(r.getBoMonId())
                        .quotaInstruct(r.getQuotaInstruct())
                        .currentInstruct(r.getCurrentInstruct())
                        .remaining(r.getRemaining())
                        .build())
                .toList();
    }



    private String getCurrentUsername() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        try { return auth.getName(); }
        catch (Exception e) { throw new ApplicationException(ErrorCode.UNAUTHENTICATED); }
    }


    public Page<SinhVienSupervisedResponse> getMySinhVienSupervised(Pageable pageable) {
        String email = currentEmail();

        Long gvhdId = giangVienRepository.findByUser_Email(email)
                .orElseThrow(() -> new ApplicationException(ErrorCode.NOT_A_GVHD))
                .getId();

        DotBaoVe dotBaoVe = timeGatekeeper.getCurrentDotBaoVe();
        Page<SinhVien> page = sinhVienRepository.findByDeTai_GiangVienHuongDan_IdAndDeTai_DotBaoVe(gvhdId, dotBaoVe, pageable);
        return page.map(sinhVienMapper::toSinhVienSupervisedResponse);
    }

    public List<SinhVienSupervisedResponse> getMySinhVienSupervisedList() {
        String email = currentEmail();

        Long gvhdId = giangVienRepository.findByUser_Email(email)
                .orElseThrow(() -> new ApplicationException(ErrorCode.NOT_A_GVHD))
                .getId();

        DotBaoVe dotBaoVe = timeGatekeeper.getCurrentDotBaoVe();
        List<SinhVien> list = sinhVienRepository.findByDeTai_GiangVienHuongDan_IdAndDeTai_DotBaoVeAndDeTai_TrangThaiOrderByHoTenDesc(gvhdId, dotBaoVe, TrangThaiDeTai.DA_DUYET);
        return list.stream()
                .map(sinhVienMapper::toSinhVienSupervisedResponse)
                .toList();
    }

    public Page<ApprovalSinhVienResponse> getDeTaiSinhVienApproval(TrangThaiDeTai status, Pageable pageable) {
        String email = currentEmail();

        Long gvhdId = giangVienRepository.findByUser_Email(email)
                .orElseThrow(() -> new ApplicationException(ErrorCode.NOT_A_GVHD))
                .getId();

        DotBaoVe dotBaoVe = timeGatekeeper.getCurrentDotBaoVe();

        Page<SinhVien> page = (status == null)
                ? sinhVienRepository.findByDeTai_GiangVienHuongDan_IdAndDeTai_DotBaoVe(gvhdId,dotBaoVe, pageable)
                : sinhVienRepository.findByDeTai_GiangVienHuongDan_IdAndDeTai_TrangThaiAndDeTai_DotBaoVe(gvhdId, status, dotBaoVe, pageable);

        return page.map(sinhVienMapper::toDeTaiSinhVienApprovalResponse);
    }

    public Page<ApprovalSinhVienResponse> getDeTaiSinhVienTuChoi(TrangThaiDeTai status, Pageable pageable) {
        String email = currentEmail();
        GiangVien gv = giangVienRepository.findByUser_Email(email)
                .orElseThrow(() -> new ApplicationException(ErrorCode.USER_NOT_FOUND));

        Long idBoMon = gv.getBoMon().getId();
        DotBaoVe dotBaoVe = timeGatekeeper.getCurrentDotBaoVe();

        Specification<SinhVien> spec = SinhVienSpecification.belongsToBoMonAndDotBaoVe(idBoMon, dotBaoVe);

        if (status != null) {
            spec = spec.and(SinhVienSpecification.hasStatusOrNotRegistered(status, dotBaoVe));
        }
        // Nếu status == null → lấy tất cả sinh viên thuộc bộ môn

        Page<SinhVien> page = sinhVienRepository.findAll(spec, pageable);
        return page.map(sinhVienMapper::toDeTaiSinhVienApprovalResponse);
    }

    public List<DeCuongNhanXetResponse> viewDeCuongLog(String maSinhVien) {

        List<DeCuong> deCuongs = deCuongRepository.findByDeTai_SinhVien_MaSinhVienOrderByPhienBanDesc(maSinhVien);
        if (deCuongs.isEmpty()) throw new ApplicationException(ErrorCode.DE_CUONG_NOT_FOUND);

        List<Long> ids = deCuongs.stream().map(DeCuong::getId).toList();
        List<NhanXetDeCuong> allComments = deCuongLogRepository.findByDeCuong_IdInOrderByCreatedAtDesc(ids);
        Map<Long, List<NhanXetDeCuong>> commentsByDeCuongId = allComments.stream().collect(Collectors.groupingBy(c -> c.getDeCuong().getId()));
        List<DeCuongNhanXetResponse> responses = deCuongMapper.toDeCuongNhanXetResponse(deCuongs);
        for (DeCuongNhanXetResponse res : responses) {
            List<NhanXetDeCuong> cList = commentsByDeCuongId.getOrDefault(res.getId(), List.of());
            res.setNhanXets(deCuongMapper.toNhanXetDeCuongResponse(cList));
        }
        return responses;
    }

    public Set<GiangVienInfoResponse> getGiangVienByBoMonAndSoLuongDeTai(Long boMonId) {
        BoMon boMon = boMonRepository.findById(boMonId)
                .orElseThrow(() -> new ApplicationException(ErrorCode.BO_MON_NOT_FOUND));
        Set<GiangVien> giangVienSet = giangVienRepository.findAvailableGiangVienByBoMon(boMonId);
        Set<GiangVienInfoResponse> responses = giangVienSet.stream()
                .map(giangVienMapper::toGiangVienInfoResponse)
                .collect(Collectors.toSet());
        responses.forEach(response -> {
            int soLuongDeTai = giangVienRepository.countDeTaiByGiangVienAndSinhVienActive(response.getMaGV());
            response.setSoLuongDeTai(soLuongDeTai);
        });
        return responses;
    }

    public Set<GiangVienInfoResponse> getGiangVienByBoMon() {
        String email = getCurrentUsername();
        GiangVien gv = giangVienRepository.findByUser_Email(email)
                .orElseThrow(() -> new ApplicationException(ErrorCode.GIANG_VIEN_NOT_FOUND));
        Long boMonId = gv.getBoMon().getId();
        BoMon boMon = boMonRepository.findById(boMonId)
                .orElseThrow(() -> new ApplicationException(ErrorCode.BO_MON_NOT_FOUND));
        Set<GiangVien> giangVienSet = giangVienRepository.findAvailableGiangVienByBoMon(boMonId);
        Set<GiangVienInfoResponse> responses = giangVienSet.stream()
                .map(giangVienMapper::toGiangVienInfoResponse)
                .collect(Collectors.toSet());
        responses.forEach(response -> {
            int soLuongDeTai = giangVienRepository.countDeTaiByGiangVienAndSinhVienActive(response.getMaGV());
            response.setSoLuongDeTai(soLuongDeTai);
        });
        return responses;
    }


    public String capNhatSoLuongHuongDanChoTatCa(Integer soLuongMoi) {
        // 1. Lấy user đang đăng nhập
        String email = getCurrentUsername();
        GiangVien currentUser = giangVienRepository.findByUser_Email(email)
                .orElseThrow(() -> new ApplicationException(ErrorCode.GIANG_VIEN_NOT_FOUND));

        // 2. Kiểm tra giá trị đầu vào
        if (soLuongMoi == null || soLuongMoi < 0) {
            throw new ApplicationException(ErrorCode.INVALID_QUOTA_VALUE);
        }

        List<GiangVien> danhSachCapNhat;

        // 3. Xác định phạm vi cập nhật
        if (isTruongBoMon(currentUser)) {
            // Là trưởng bộ môn → chỉ cập nhật trong bộ môn
            BoMon boMon = currentUser.getBoMon();
            if (boMon == null) {
                throw new ApplicationException(ErrorCode.BO_MON_NOT_FOUND);
            }
            danhSachCapNhat = giangVienRepository.findByBoMon_Id(boMon.getId());
        } else {
            // Không phải trưởng bộ môn → cập nhật toàn hệ thống
            danhSachCapNhat = giangVienRepository.findAll();
        }

        // 4. Kiểm tra có dữ liệu để cập nhật
        if (danhSachCapNhat.isEmpty()) {
            throw new ApplicationException(ErrorCode.NO_GIANGVIEN_FOUND);
        }

        // 5. Cập nhật quota
        danhSachCapNhat.forEach(gv -> gv.setQuotaInstruct(soLuongMoi));

        // 6. Lưu
        giangVienRepository.saveAll(danhSachCapNhat);

        // 7. Trả về thông báo phù hợp
        String scope = isTruongBoMon(currentUser)
                ? "bộ môn " + currentUser.getBoMon().getTenBoMon()
                : "toàn hệ thống";

        return "Cập nhật thành công số lượng hướng dẫn cho "
                + danhSachCapNhat.size() + " giảng viên (" + scope + ").";
    }
    private boolean isTruongBoMon(GiangVien gv) {
        return gv.getBoMon() != null
                && gv.getBoMon().getTruongBoMon() != null
                && gv.getBoMon().getTruongBoMon().getId().equals(gv.getId());
    }

    public List<GiangVienLiteResponse> getGiangVienPhanBien(Long idBoMon, Long idGiangVienHuongDan) {
        // 1. Kiểm tra bộ môn tồn tại
        BoMon boMon = boMonRepository.findById(idBoMon)
                .orElseThrow(() -> new ApplicationException(ErrorCode.BO_MON_NOT_FOUND));

        // 2. Lấy danh sách giảng viên trong bộ môn, sắp xếp theo họ tên
        List<GiangVien> danhSachGV = giangVienRepository
                .findByBoMon_IdOrderByHoTenAsc(boMon.getId());

        // 3. Loại bỏ giảng viên hướng dẫn (nếu có trong danh sách)
        return danhSachGV.stream()
                .filter(gv -> !gv.getId().equals(idGiangVienHuongDan)) // Loại bỏ GVHD
                .map(giangVienMapper::toLite)
                .toList();
    }

    public List<SinhVienSupervisedResponse> getMySinhVienSupervisedAll(String q) {
        String email = currentEmail();

        Long gvhdId = giangVienRepository.findByUser_Email(email)
                .orElseThrow(() -> new ApplicationException(ErrorCode.NOT_A_GVHD))
                .getId();

        DotBaoVe dotBaoVe = timeGatekeeper.getCurrentDotBaoVe();

        final List<SinhVien> list = (q == null || q.isBlank())
                ? sinhVienRepository.findByDeTai_GiangVienHuongDan_IdAndDeTai_DotBaoVeOrderByHoTenAsc(gvhdId, dotBaoVe)
                : sinhVienRepository.searchMySupervisedAll(gvhdId, dotBaoVe, q.trim());

        // map sang DTO response
        return list.stream()
                .map(sinhVienMapper::toStudentSupervisedResponse)
                .toList();
    }


    public GiangVienCreationResponse createGiangVien(GiangVienCreationRequest giangVienCreationRequest) {

        if(giangVienRepository.existsByMaGiangVien(giangVienCreationRequest.getMaGiangVien())) {
            throw new ApplicationException(ErrorCode.MA_GV_EXISTED);
        }
        if(taiKhoanRepository.existsByEmail((giangVienCreationRequest.getEmail()))) {
            throw new ApplicationException(ErrorCode.EMAIL_EXISTED);
        }

        var auth = SecurityContextHolder.getContext().getAuthentication();
        User currentUser = taiKhoanRepository.findByEmail(auth.getName())
                .orElseThrow(() -> new ApplicationException(ErrorCode.USER_NOT_FOUND));

        User taiKhoan = User.builder()
                .email(giangVienCreationRequest.getEmail())
                .matKhau(passwordEncoder.encode(giangVienCreationRequest.getMatKhau()))
                .vaiTro(Role.GIANG_VIEN)
                .trangThaiKichHoat(true)
                .build();

        BoMon boMon = boMonRepository.findById(giangVienCreationRequest.getIdBoMon())
                .orElseThrow(() -> new ApplicationException(ErrorCode.BO_MON_NOT_FOUND));

        GiangVien giangVien = GiangVien.builder()
                .hocVi(giangVienCreationRequest.getHocVi())
                .hocHam(giangVienCreationRequest.getHocHam())
                .maGiangVien(giangVienCreationRequest.getMaGiangVien())
                .hoTen(giangVienCreationRequest.getHoTen())
                .boMon(boMon)
                .soDienThoai(giangVienCreationRequest.getSoDienThoai())
                .user(taiKhoan)
                .quotaInstruct(0)
                .build();

        if(currentUser.getVaiTro() == Role.QUAN_TRI_VIEN){
            taiKhoan.setVaiTro(Role.TRO_LY_KHOA);
        }
        taiKhoan.setGiangVien(giangVien);
        taiKhoanRepository.save(taiKhoan);
        return giangVienMapper.toGiangVienCreationResponse(giangVienRepository.save(giangVien));

    }


    public void createTroLyKhoa(TroLyKhoaCreationRequest troLyKhoaCreationRequest) {
        GiangVien troLyKhoa = giangVienRepository.findById(troLyKhoaCreationRequest.getGiangVienId())
                .orElseThrow(() -> new ApplicationException(ErrorCode.GIANG_VIEN_NOT_FOUND));
        if(troLyKhoa.getUser().getVaiTro() == Role.TRUONG_BO_MON){
            throw new ApplicationException(ErrorCode.INVALID_TRO_LY_KHOA);
        }
        if(troLyKhoa.getUser().getVaiTro() == Role.TRO_LY_KHOA){
            return;
        }
        troLyKhoa.getUser().setVaiTro(Role.TRO_LY_KHOA);
        giangVienRepository.save(troLyKhoa);
    }


    public GiangVienImportResponse importGiangVien(MultipartFile file) throws IOException {
        int total = 0, ok = 0;
        List<String> errs = new ArrayList<>();

        try (InputStream in = file.getInputStream();
             XSSFWorkbook wb = new XSSFWorkbook(in)) {

            XSSFSheet sheet = wb.getSheetAt(0);
            DataFormatter fmt = new DataFormatter();     // đọc mọi cell -> String, không mất số đầu
            Map<String,Integer> col = headerIndex(sheet.getRow(0));

            for (int i = 1; i <= sheet.getLastRowNum(); i++) {
                Row r = sheet.getRow(i);
                if (r == null) continue;
                total++;

                try {
                    String maGV    = fmt.formatCellValue(r.getCell(col.get("Mã giảng viên"))).trim();
                    String hoTen   = fmt.formatCellValue(r.getCell(col.get("Họ tên"))).trim();
                    String sdt     = fmt.formatCellValue(r.getCell(col.get("Số điện thoại"))).trim();
                    String email   = fmt.formatCellValue(r.getCell(col.get("Email"))).trim().toLowerCase();
                    String matKhau = fmt.formatCellValue(r.getCell(col.get("Mật khẩu"))).trim();
                    String boMonTx = fmt.formatCellValue(r.getCell(col.get("Bộ môn"))).trim();
                    String hocVi   = fmt.formatCellValue(r.getCell(col.get("Học vị"))).trim();
                    String hocHam  = fmt.formatCellValue(r.getCell(col.get("Học hàm"))).trim();

                    // Lấy boMonId: nếu cột là ID thì parse, còn không thì tìm theo tên
                    Long boMonId = tryParseLong(boMonTx);
                    if (boMonId == null) {
                        boMonId = boMonRepository.findByTenBoMon((boMonTx))
                                .orElseThrow(() -> new ApplicationException(ErrorCode.BO_MON_NOT_FOUND))
                                .getId();
                    }

                    var req = GiangVienCreationRequest.builder()
                            .maGiangVien(maGV)
                            .hoTen(hoTen)
                            .soDienThoai(sdt)
                            .email(email)
                            .matKhau(matKhau)
                            .hocVi(hocVi)
                            .hocHam(hocHam)
                            .idBoMon(boMonId)
                            .build();

                    createGiangVien(req);  // tái dùng logic hiện có
                    ok++;

                } catch (ApplicationException ex) {
                    errs.add("Row " + (i + 1) + ": " + ex.getErrorCode().name());
                } catch (Exception ex) {
                    errs.add("Row " + (i + 1) + ": " + ex.getMessage());
                }
            }
        }

        return GiangVienImportResponse.builder()
                .totalRows(total)
                .success(ok)
                .errors(errs)
                .build();
    }

    private Map<String,Integer> headerIndex(Row header) {
        Map<String,Integer> m = new HashMap<>();
        DataFormatter fmt = new DataFormatter();
        for (int c = 0; c < header.getLastCellNum(); c++) {
            m.put(fmt.formatCellValue(header.getCell(c)).trim(), c);
        }
        return m;
    }
    private Long tryParseLong(String s) {
        try { return Long.valueOf(s); } catch (Exception e) { return null; }
    }
    private String currentEmail() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || auth.getName() == null) {
            throw new ApplicationException(ErrorCode.UNAUTHENTICATED);
        }
        return auth.getName();
    }


    public List<GiangVienLiteResponse> getGiangVienLiteByBoMon(Long boMonId) {
        BoMon bm = boMonRepository.findById(boMonId)
                .orElseThrow(() -> new ApplicationException(ErrorCode.BO_MON_NOT_FOUND));
        return giangVienRepository.findByBoMon_IdOrderByHoTenAsc(bm.getId())
                .stream()
                .map(giangVienMapper::toLite)
                .toList();
    }

    public GiangVienProfileResponse getMyProfile() {
        String email = currentEmail();
        GiangVien gv = giangVienRepository.findByUser_Email(email)
                .orElseThrow(() -> new ApplicationException(ErrorCode.GIANG_VIEN_NOT_FOUND));
        return giangVienMapper.toGiangVienProfileResponse(gv);
    }


    public Page<GiangVienResponse> getAllGiangVien(Pageable pageable) {
        Page<GiangVien> page = giangVienRepository.findAll(pageable);
        return page.map(giangVienMapper::toGiangVienResponse);
    }


    public GiangVienResponse updateGiangVien(Long id, GiangVienUpdateRequest request) {
        GiangVien existingGV = giangVienRepository.findById(id)
                .orElseThrow(() -> new ApplicationException(ErrorCode.GIANG_VIEN_NOT_FOUND));

        User taiKhoan = existingGV.getUser();

        // Check email duplication
        if (taiKhoanRepository.existsByEmail(request.getEmail())
                && !taiKhoan.getEmail().equals(request.getEmail())) {
            throw new ApplicationException(ErrorCode.EMAIL_EXISTED);
        }

        // Validate password
        if (request.getMatKhau() != null && !request.getMatKhau().isBlank()
                && request.getMatKhau().length() < 6) {
            throw new ApplicationException(ErrorCode.PASSWORD_INVALID);
        }

        // Update tài khoản
        taiKhoan.setEmail(request.getEmail());
        if (request.getMatKhau() != null && !request.getMatKhau().isBlank()) {
            taiKhoan.setMatKhau(passwordEncoder.encode(request.getMatKhau()));
        }
        taiKhoanRepository.save(taiKhoan);

        // Update thông tin giảng viên
        existingGV.setHoTen(request.getHoTen());
        existingGV.setSoDienThoai(request.getSoDienThoai());
        existingGV.setHocVi(request.getHocVi());
        existingGV.setHocHam(request.getHocHam());

        if (request.getBoMonId() != null) {
            BoMon bm = boMonRepository.findById(request.getBoMonId())
                    .orElseThrow(() -> new ApplicationException(ErrorCode.BO_MON_NOT_FOUND));
            existingGV.setBoMon(bm);
        }

        return giangVienMapper.toGiangVienResponse(giangVienRepository.save(existingGV));
    }



}
