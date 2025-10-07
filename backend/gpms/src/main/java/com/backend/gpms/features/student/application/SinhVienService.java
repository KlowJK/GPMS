package  com.backend.gpms.features.student.application;

import com.backend.gpms.common.exception.ApplicationException;
import com.backend.gpms.common.exception.ErrorCode;
import com.backend.gpms.common.mapper.SinhVienMapper;
import com.backend.gpms.features.auth.domain.Role;
import com.backend.gpms.features.auth.domain.User;
import com.backend.gpms.features.auth.infra.UserRepository;
import com.backend.gpms.features.department.domain.Lop;
import com.backend.gpms.features.department.infra.LopRepository;
import com.backend.gpms.features.storage.application.StorageService;
import com.backend.gpms.features.student.domain.SinhVien;
import com.backend.gpms.features.student.dto.request.SinhVienCreationRequest;
import com.backend.gpms.features.student.dto.request.SinhVienUpdateRequest;
import com.backend.gpms.features.student.dto.response.*;
import com.backend.gpms.features.student.infra.SinhVienRepository;
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
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
@RequiredArgsConstructor
@Transactional
public class SinhVienService {

    SinhVienRepository sinhVienRepository;
    LopRepository lopRepository;
    PasswordEncoder passwordEncoder;
    SinhVienMapper sinhVienMapper;
    UserRepository taiKhoanRepository;
    StorageService cloudinaryService;

    @PreAuthorize("hasAuthority('SCOPE_TRO_LY_KHOA')")
    public SinhVienCreationResponse createSinhVien(SinhVienCreationRequest request) {

        if(taiKhoanRepository.existsByEmail(request.getEmail())) {
            throw new ApplicationException(ErrorCode.EMAIL_EXISTED);
        }
        if(sinhVienRepository.existsByMaSinhVien(request.getMaSinhVien())) {
            throw new ApplicationException(ErrorCode.MA_SV_EXISTED);
        }

        Lop lop = lopRepository.findById(request.getIdLop())
                .orElseThrow(() -> new ApplicationException(ErrorCode.LOP_NOT_FOUND));

        User taiKhoan = User.builder()
                .email(request.getEmail())
                .matKhau(passwordEncoder.encode(request.getMatKhau()))
                .vaiTro(Role.SINH_VIEN)
                .trangThaiKichHoat(true)
                .build();

        SinhVien sinhVien = SinhVien.builder()
                .hoTen(request.getHoTen())
                .maSinhVien(request.getMaSinhVien())
                .lop(lop)
                .user(taiKhoan)
                .soDienThoai(request.getSoDienThoai())
                .build();
        taiKhoan.setSinhVien(sinhVien);
        taiKhoanRepository.save(taiKhoan);
        return sinhVienMapper.toSinhVienCreationResponse(sinhVienRepository.save(sinhVien));

    }



    @PreAuthorize("hasAuthority('SCOPE_TRO_LY_KHOA')")
    public SinhVienImportResponse importSinhVien(MultipartFile file) throws IOException {
        int total = 0, ok = 0;
        List<String> errs = new ArrayList<>();

        try (InputStream in = file.getInputStream();
             XSSFWorkbook wb = new XSSFWorkbook(in)) {

            XSSFSheet sheet = wb.getSheetAt(0);
            DataFormatter fmt = new DataFormatter();

            Map<String,Integer> col = headerIndex(sheet.getRow(0));

            for (int i = 1; i <= sheet.getLastRowNum(); i++) {
                Row r = sheet.getRow(i);
                if (r == null) continue;
                total++;

                try {
                    String maSV       = fmt.formatCellValue(r.getCell(col.get("Mã Sinh Viên")));
                    String hoTen      = fmt.formatCellValue(r.getCell(col.get("Họ tên")));
                    String sdt        = fmt.formatCellValue(r.getCell(col.get("Số điện thoại")));
                    String email      = fmt.formatCellValue(r.getCell(col.get("Email")));
                    String matKhau    = fmt.formatCellValue(r.getCell(col.get("Mật khẩu")));
                    String lopText    = fmt.formatCellValue(r.getCell(col.get("Lớp")));

                    Long lopId = tryParseLong(lopText);
                    if (lopId == null) {
                        lopId = lopRepository.findByTenLop((lopText))
                                .orElseThrow(() -> new ApplicationException(ErrorCode.LOP_NOT_FOUND))
                                .getId();
                    }

                    SinhVienCreationRequest req = SinhVienCreationRequest.builder()
                            .maSinhVien(maSV)
                            .hoTen(hoTen)
                            .soDienThoai(sdt)
                            .email(email)
                            .matKhau(matKhau)
                            .idLop(lopId)
                            .build();

                    createSinhVien(req); // TÁI DÙNG logic hiện có
                    ok++;

                } catch (ApplicationException ex) {
                    errs.add("Row " + (i+1) + ": " + ex.getErrorCode().name());
                } catch (Exception ex) {
                    errs.add("Row " + (i+1) + ": " + ex.getMessage());
                }
            }
        }
        return SinhVienImportResponse.builder()
                .totalRows(total)
                .success(ok)
                .errors(errs)
                .build();
    }

    @PreAuthorize("isAuthenticated()")
    public Page<SinhVienResponse> getAllSinhVien(Pageable pageable) {
        Page<SinhVien> sinhVienPage = sinhVienRepository.findAll(pageable);
        return sinhVienPage.map(sinhVienMapper::toSinhVienResponse);
    }

    @PreAuthorize("isAuthenticated()")
    public Page<SinhVienResponse> getAllSinhVienByTenOrMaSV(String request, Pageable pageable) {
        if(request == null || request.isBlank()) {
            return getAllSinhVien(pageable);
        }
        Page<SinhVien> sinhVienPage = sinhVienRepository.findAllByHoTenContainingIgnoreCaseOrMaSinhVienContainingIgnoreCase(
                request, request, pageable);
        return sinhVienPage.map(sinhVienMapper::toSinhVienResponse);
    }

    @PreAuthorize("hasAuthority('SCOPE_TRO_LY_KHOA')")
    public void changeSinhVienStatus(String maSV) {

        SinhVien sinhVien = sinhVienRepository.findByMaSinhVien((maSV))
                .orElseThrow(() -> new ApplicationException(ErrorCode.SINH_VIEN_NOT_FOUND));
        sinhVien.setDuDieuKien(!sinhVien.getDuDieuKien());
        sinhVienRepository.save(sinhVien);

    }

    @PreAuthorize("hasAuthority('SCOPE_TRO_LY_KHOA')")

    public SinhVienCreationResponse updateSinhVien(SinhVienUpdateRequest request, String maSV) {
        SinhVien existingSinhVien = sinhVienRepository.findByMaSinhVien(maSV)
                .orElseThrow(() -> new ApplicationException(ErrorCode.SINH_VIEN_NOT_FOUND));
        if (taiKhoanRepository.existsByEmail(request.getEmail())
                && !existingSinhVien.getUser().getEmail().equals(request.getEmail())) {
            throw new ApplicationException(ErrorCode.EMAIL_EXISTED);
        }

        if (request.getMatKhau() != null && !request.getMatKhau().isBlank() && request.getMatKhau().length() < 6) {
            throw new ApplicationException(ErrorCode.PASSWORD_INVALID);
        }

        Lop lop = lopRepository.findById(request.getLopId())
                .orElseThrow(() -> new ApplicationException(ErrorCode.LOP_NOT_FOUND));
        User taiKhoan = existingSinhVien.getUser();
        taiKhoan.setEmail(request.getEmail());
        if(request.getMatKhau() != null && !request.getMatKhau().isBlank()) {
            taiKhoan.setMatKhau(passwordEncoder.encode(request.getMatKhau()));
        }
        taiKhoanRepository.save(taiKhoan);
        existingSinhVien.setHoTen(request.getHoTen());
        existingSinhVien.setSoDienThoai(request.getSoDienThoai());
        existingSinhVien.setLop(lop);
        return sinhVienMapper.toSinhVienCreationResponse(sinhVienRepository.save(existingSinhVien));
    }

    @PreAuthorize("isAuthenticated()")
    public SinhVienInfoResponse getSinhVienInfo(String maSV) {
        SinhVien sinhVien = sinhVienRepository.findByMaSinhVien(maSV)
                .orElseThrow(() -> new ApplicationException(ErrorCode.SINH_VIEN_NOT_FOUND));
        return sinhVienMapper.toSinhVienInfoResponse(sinhVien);
    }

    @PreAuthorize("isAuthenticated()")
    public List<GetSinhVienWithoutDeTaiResponse> getSinhVienWithoutDeTai() {
        List<SinhVien> sinhVienList = sinhVienRepository.findAllByDeTaiIsNullAndUser_TrangThaiKichHoatTrue();
        return sinhVienList.stream()
                .map(sinhVienMapper::toGetSinhVienWithoutDeTaiResponse)
                .toList();
    }

    @PreAuthorize("hasAuthority('SCOPE_SINH_VIEN')")
    public void uploadCV(MultipartFile file) throws IOException {
        var auth = SecurityContextHolder.getContext().getAuthentication();
        SinhVien sinhVien = sinhVienRepository.findByUser_Email(auth.getName())
                .orElseThrow(() -> new ApplicationException(ErrorCode.SINH_VIEN_NOT_FOUND));
        if (file.isEmpty()) {
            return;
        }
        if (!file.getContentType().equals("application/pdf")) {
            throw new ApplicationException(ErrorCode.INVALID_FILE_TYPE);
        }
        if (file.getSize() > 10 * 1024 * 1024) {
            throw new ApplicationException(ErrorCode.FILE_TOO_LARGE);
        }
        String fileUrl = cloudinaryService.uploadRawFile(file);
        sinhVien.setDuongDanCv(fileUrl);
        sinhVienRepository.save(sinhVien);
    }

    private Map<String,Integer> headerIndex(Row header) {
        Map<String,Integer> m = new HashMap<>();
        for (int c = 0; c < header.getLastCellNum(); c++) {
            m.put(new DataFormatter().formatCellValue(header.getCell(c)).trim(), c);
        }
        return m;
    }
    private Long tryParseLong(String s) {
        try { return Long.valueOf(s); } catch (Exception e) { return null; }
    }
    private String getCurrentUsername() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || auth.getName() == null) {
            throw new ApplicationException(ErrorCode.UNAUTHENTICATED);
        }
        return auth.getName();
    }

    private String upload(org.springframework.web.multipart.MultipartFile file) {
        try { return cloudinaryService.upload(file); }
        catch (Exception e) { throw new ApplicationException(ErrorCode.UPLOAD_FILE_FAILED); }
    }
}
