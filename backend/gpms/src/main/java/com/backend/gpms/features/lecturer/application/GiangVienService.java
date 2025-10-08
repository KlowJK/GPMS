package com.backend.gpms.features.lecturer.application;

import com.backend.gpms.common.exception.ApplicationException;
import com.backend.gpms.common.exception.ErrorCode;
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
import com.backend.gpms.features.student.domain.SinhVien;
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

    private final SinhVienRepository sinhVienRepository;
    private final BoMonRepository boMonRepository;
    private final GiangVienRepository giangVienRepository;
    private final DeTaiRepository deTaiRepository;
    private final NganhRepository nganhRepository;
    private final UserRepository taiKhoanRepository;
    private final PasswordEncoder passwordEncoder;
    private final GiangVienMapper giangVienMapper;
    SinhVienMapper sinhVienMapper;
    private final TimeGatekeeper timeGatekeeper;

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




    public Page<SinhVienSupervisedResponse> getMySinhVienSupervised(Pageable pageable) {
        String email = currentEmail();

        Long gvhdId = giangVienRepository.findByUser_Email(email)
                .orElseThrow(() -> new ApplicationException(ErrorCode.NOT_A_GVHD))
                .getId();

        DotBaoVe dotBaoVe = timeGatekeeper.getCurrentDotBaoVe();
        Page<SinhVien> page = sinhVienRepository.findByDeTai_GiangVienHuongDan_IdAndDeTai_DotBaoVe(gvhdId, dotBaoVe, pageable);
        return page.map(sinhVienMapper::toSinhVienSupervisedResponse);
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
