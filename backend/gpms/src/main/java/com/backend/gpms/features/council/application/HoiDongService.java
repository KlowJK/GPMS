package com.backend.gpms.features.council.application;

import com.backend.gpms.common.exception.ApplicationException;
import com.backend.gpms.common.exception.ErrorCode;
import com.backend.gpms.common.mapper.HoiDongMapper;
import com.backend.gpms.common.util.TimeGatekeeper;
import com.backend.gpms.features.council.domain.*;
import com.backend.gpms.features.council.dto.request.HoiDongRequest;
import com.backend.gpms.features.council.dto.request.PhanCongBaoVeRequest;
import com.backend.gpms.features.council.dto.request.PhanCongPhanBienRequest;
import com.backend.gpms.features.council.dto.response.HoiDongResponse;
import com.backend.gpms.features.council.dto.response.PhanCongBaoVeResponse;
import com.backend.gpms.features.council.dto.response.PhanCongPhanBienResponse;
import com.backend.gpms.features.council.dto.response.ThanhVienHoiDongResponse;
import com.backend.gpms.features.council.infra.HoiDongRepository;
import com.backend.gpms.features.council.infra.PhanCongBaoVeRepository;
import com.backend.gpms.features.council.infra.PhanCongPhanBienRepository;
import com.backend.gpms.features.council.infra.ThanhVienHoiDongRepository;
import com.backend.gpms.features.defense.domain.DotBaoVe;
import com.backend.gpms.features.defense.infra.DotBaoVeRepository;
import com.backend.gpms.features.lecturer.domain.GiangVien;
import com.backend.gpms.features.lecturer.infra.GiangVienRepository;
import com.backend.gpms.features.outline.domain.TrangThaiDuyetDon;
import com.backend.gpms.features.progress.domain.BaoCao;
import com.backend.gpms.features.progress.infra.BaoCaoRepository;
import com.backend.gpms.features.score.domain.DiemBaoVeChiTiet;
import com.backend.gpms.features.score.domain.DiemPhanBien;
import com.backend.gpms.features.score.infra.DiemBaoVeChiTietRepository;
import com.backend.gpms.features.score.infra.DiemPhanBienRepository;
import com.backend.gpms.features.score.infra.DiemRepository;
import com.backend.gpms.features.storage.application.StorageService;
import com.backend.gpms.features.topic.domain.DeTai;
import com.backend.gpms.features.topic.domain.TrangThaiDeTai;
import com.backend.gpms.features.topic.infra.DeTaiRepository;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.*;
import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class HoiDongService{

    HoiDongRepository hoiDongRepository;
    HoiDongMapper hoiDongMapper;
    DeTaiRepository deTaiRepository;
    DotBaoVeRepository dotBaoVeRepository;
    GiangVienRepository giangVienRepository;
    ThanhVienHoiDongRepository thanhVienHoiDongRepository;
    StorageService cloudinaryService;
    TimeGatekeeper timeGatekeeper;
    PhanCongPhanBienRepository phanCongPhanBienRepository;
    PhanCongBaoVeRepository phanCongBaoVeRepository;
    DiemPhanBienRepository diemPhanBienRepository;
    DiemBaoVeChiTietRepository diemBaoVeChiTietRepository;
    DiemRepository diemRepository;
    BaoCaoRepository baoCaoRepository;


    @PersistenceContext
    EntityManager em;


    public Page<HoiDongResponse> getHoiDongsDangDienRa(
            String keyword, Long idDetai, Long idGiangVien, Pageable pageable) {

        DotBaoVe dotBaoVe = timeGatekeeper.getCurrentDotBaoVe();
        boolean hasKeyword = StringUtils.hasText(keyword);
        boolean hasIdDetai = idDetai != null && idDetai > 0;
        boolean hasIdGiangVien = idGiangVien != null && idGiangVien > 0;

        Page<HoiDong> page;

        if (hasKeyword) {
            page = hoiDongRepository.findHoiDongByDotBaoVeAndTenHoiDongContainingIgnoreCase(
                    dotBaoVe, keyword.trim(), pageable);

        } else if (hasIdDetai) {
            page = hoiDongRepository.findByDotBaoVeAndDeTaiSet_Id(dotBaoVe, idDetai, pageable);

        } else if (hasIdGiangVien) {
            page = hoiDongRepository.findHoiDongByGiangVienPhanBienOrThanhVien(
                    dotBaoVe, idGiangVien, pageable);

        } else {
            page = hoiDongRepository.findHoiDongByDotBaoVe(dotBaoVe, pageable);
        }

        return page.map(hoiDongMapper::toListItem);
    }

    public List<HoiDongResponse> getHoiDongsDangDienRa(String keyword,Long idDetai,Long idGiangVien) {
        boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();
        boolean hasIdDetai = idDetai != null && idDetai >0;
        boolean hasIdGiangVien = idGiangVien != null && idGiangVien >0;

        DotBaoVe dotBaoVe = timeGatekeeper.getCurrentDotBaoVe();

        List<HoiDong> list;
        if (hasKeyword) {
            list = hoiDongRepository.findHoiDongByDotBaoVeAndTenHoiDongContainingIgnoreCase(dotBaoVe, keyword);
        }else
        if (hasIdDetai) {
            list = hoiDongRepository.findByDotBaoVeAndDeTaiSet_Id(dotBaoVe, idDetai);
        } else
        if (hasIdGiangVien) {
            list = hoiDongRepository.findByDotBaoVeAndThanhVienHoiDongSet_GiangVien_Id(dotBaoVe,idGiangVien);
        } else {
            list = hoiDongRepository.findHoiDongByDotBaoVe(dotBaoVe);
        }

        return list.stream().map(hoiDongMapper::toListItem).collect(java.util.stream.Collectors.toList());
    }


    public ThanhVienHoiDongResponse getHoiDongDetail(Long hoiDongId) {
        HoiDong hd = hoiDongRepository.fetchDetail(hoiDongId)
                .orElseThrow(() -> new ApplicationException(ErrorCode.HOI_DONG_NOT_FOUND));
        return hoiDongMapper.toDetail(hd);
    }


    public Page<HoiDongResponse> getTatCaHoiDongByDot(Long dotBaoVeId, String keyword, Pageable pageable) {
        if (dotBaoVeId == null) {
            throw new ApplicationException(ErrorCode.DOT_BAO_VE_NOT_FOUND);
        }

        boolean hasKeyword = keyword != null && !keyword.isBlank();

        Page<HoiDong> page;
     if (hasKeyword) {
            page = hoiDongRepository
                    .findByDotBaoVe_IdAndTenHoiDongContainingIgnoreCase(dotBaoVeId, keyword, pageable);
        } else {
            page = hoiDongRepository
                    .findByDotBaoVe_Id(dotBaoVeId, pageable);
        }

        return page.map(hoiDongMapper::toListItem);
    }


    public ThanhVienHoiDongResponse createHoiDong(HoiDongRequest request) {
        // 1. Kiểm tra đợt bảo vệ
        DotBaoVe dot = dotBaoVeRepository.findById(request.getDotBaoVeId())
                .orElseThrow(() -> new ApplicationException(ErrorCode.DOT_BAO_VE_NOT_FOUND));

        // 2. Kiểm tra thời gian
        LocalDate start = request.getThoiGianBatDau();
        LocalDate end = request.getThoiGianKetThuc();
        if (start.isAfter(end)) {
            throw new ApplicationException(ErrorCode.INVALID_TIME_RANGE);
        }
        if (start.isBefore(dot.getNgayBatDau()) || end.isAfter(dot.getNgayKetThuc())) {
            throw new ApplicationException(ErrorCode.INVALID_TIME_RANGE);
        }
        GiangVien chuTich = getGiangVienById(request.getChuTichId());
        GiangVien thuKy = getGiangVienById(request.getThuKyId());
        HoiDong hd = new HoiDong();
        hd.setTenHoiDong(request.getTenHoiDong());
        hd.setThoiGianBatDau(start);
        hd.setThoiGianKetThuc(end);
        hd.setDiaDiem(request.getDiaDiem());
        hd.setChuTich(chuTich);
        hd.setThuKy(thuKy);
        hd.setDotBaoVe(dot);
        hd.setDeTaiSet(new HashSet<>());
        hd.setThanhVienHoiDongSet(new HashSet<>());

        HoiDong saved = hoiDongRepository.save(hd);

        List<ThanhVienHoiDong> members = new ArrayList<>();
        members.add(createThanhVien(saved, chuTich, ChucVuHoiDong.CHU_TICH));
        members.add(createThanhVien(saved, thuKy, ChucVuHoiDong.THU_KY));
        List<HoiDongRequest.LecturerItem> lecturers = request.getLecturers() != null
                ? request.getLecturers()
                : Collections.emptyList();
        for (var li : lecturers) {
            GiangVien gv = getGiangVienById(li.getGiangVienId());
            members.add(createThanhVien(saved, gv, ChucVuHoiDong.UY_VIEN));
        }

        thanhVienHoiDongRepository.saveAll(members);

        HoiDong full = hoiDongRepository.fetchDetail(saved.getId())
                .orElseThrow(() -> new ApplicationException(ErrorCode.HOI_DONG_NOT_FOUND));

        return hoiDongMapper.toDetail(full);
    }

    private GiangVien getGiangVienById(Long id) {
        return giangVienRepository.findById(id)
                .orElseThrow(() -> new ApplicationException(ErrorCode.GIANG_VIEN_NOT_FOUND));
    }

    private ThanhVienHoiDong createThanhVien(HoiDong hd, GiangVien gv, ChucVuHoiDong vaiTro) {
        ThanhVienHoiDong tv = new ThanhVienHoiDong();
        tv.setHoiDong(hd);
        tv.setGiangVien(gv);
        tv.setVaiTro(vaiTro);
        return tv;
    }

    public PhanCongBaoVeResponse importSinhVienToHoiDong(Long hoiDongId, MultipartFile excelFile) {
        HoiDong hd = hoiDongRepository.findById(hoiDongId)
                .orElseThrow(() -> new ApplicationException(ErrorCode.HOI_DONG_NOT_FOUND));
        DotBaoVe dot = hd.getDotBaoVe();

        Set<DeTai> newSet = new HashSet<>();
        int success = 0;

        List<PhanCongBaoVeResponse.FailureItem> failures = new ArrayList<>();
        List<ImportLogRow> logs = new ArrayList<>();

        try (InputStream is = excelFile.getInputStream(); Workbook wb = new XSSFWorkbook(is)) {
            Sheet sheet = wb.getSheetAt(0);
            DataFormatter fmt = new DataFormatter();

            for (int i = 1; i <= sheet.getLastRowNum(); i++) {
                Row r = sheet.getRow(i);
                if (r == null) continue;

                String maSv  = fmt.formatCellValue(r.getCell(0)).trim();  // A: Mã SV
                String tenDt = fmt.formatCellValue(r.getCell(1)).trim();  // B: Tên đề tài

                if (maSv.isEmpty() || tenDt.isEmpty()) {
                    String reason = "Thiếu dữ liệu";
                    failures.add(fail(maSv, tenDt, reason));
                    logs.add(new ImportLogRow(maSv, tenDt, false, reason));
                    continue;
                }

                List<DeTai> candidates = deTaiRepository
                        .findBySinhVien_MaSinhVienIgnoreCaseAndDotBaoVe_IdAndTrangThai(
                                maSv, dot.getId(), TrangThaiDeTai.DA_DUYET);

                if (candidates.isEmpty()) {
                    String reason = "Sinh viên chưa có đề tài được duyệt trong đợt này";
                    failures.add(fail(maSv, tenDt, reason));
                    logs.add(new ImportLogRow(maSv, tenDt, false, reason));
                    continue;
                }

                String want = norm(tenDt);
                DeTai dt = null;
                for (DeTai d : candidates) {
                    if (norm(d.getTenDeTai()).equals(want)) { dt = d; break; }
                }

                if (dt == null) {
                    String reason = "Tên đề tài trong file không khớp hệ thống";
                    failures.add(fail(maSv, tenDt, reason));
                    logs.add(new ImportLogRow(maSv, tenDt, false, reason));
                    continue;
                }

                boolean conflicted = hoiDongRepository
                        .existsByDotBaoVe_IdAndDeTaiSet_IdAndIdNot(
                                dot.getId(), dt.getId(), hd.getId()
                        );

                if (conflicted) {

                    String extra = hoiDongRepository
                            .findFirstByDotBaoVe_IdAndDeTaiSet_IdAndIdNot(
                                    dot.getId(), dt.getId(), hd.getId()
                            )
                            .map(x -> " (" + x.getTenHoiDong() + ")")
                            .orElse("");

                    String reason = "Đã thuộc HĐ  khác trong đợt này" + extra;
                    failures.add(fail(maSv, tenDt, reason));
                    logs.add(new ImportLogRow(maSv, tenDt, false, reason));
                    continue;
                }

                LocalDate s = hd.getThoiGianBatDau(), e = hd.getThoiGianKetThuc();
                if (s.isBefore(dot.getNgayBatDau()) || e.isAfter(dot.getNgayKetThuc())) {
                    String reason = "Thời gian hội đồng không thuộc đợt";
                    failures.add(fail(maSv, tenDt, reason));
                    logs.add(new ImportLogRow(maSv, tenDt, false, reason));
                    continue;
                }

                // OK
                newSet.add(dt);
                success++;
                // thành công: để trống lý do
                logs.add(new ImportLogRow(maSv, tenDt, true, null));
            }
        } catch (IOException e) {
            throw new ApplicationException(ErrorCode.INVALID_VALIDATION);
        }

        if (success > 0) {
            if (hd.getDeTaiSet() == null) hd.setDeTaiSet(new HashSet<>());
            else hd.getDeTaiSet().clear();
            hd.getDeTaiSet().addAll(newSet);
            hoiDongRepository.save(hd);
        }

        // Luôn tạo log Excel
        String logUrl;
        try {
            File log = generateImportLogExcel(logs);
            logUrl = cloudinaryService.upload(log);
        } catch (Exception e) {
            throw new ApplicationException(ErrorCode.UPLOAD_FILE_FAILED);
        }

        return PhanCongBaoVeResponse.builder()
                .totalRecords(success + failures.size())
                .successCount(success)
                .failureCount(failures.size())
                .failureItems(failures)
                .logFileUrl(logUrl)
                .build();
    }

    private PhanCongBaoVeResponse.FailureItem fail(String maSv, String ten, String reason) {
        return PhanCongBaoVeResponse.FailureItem.builder()
                .maSinhVien(maSv)
                .tenDeTai(ten)
                .reason(reason)
                .build();
    }

    public PhanCongPhanBienResponse getPhanCongPhanBienByHoiDong(Long idDeTai) {
        DeTai deTai = deTaiRepository.findById(idDeTai)
                .orElseThrow(() -> new ApplicationException(ErrorCode.DE_TAI_NOT_FOUND));

        PhanCongBaoVe phanCongBaoVe = phanCongBaoVeRepository.findByDeTai_Id(idDeTai)
                .orElseThrow(() -> new ApplicationException(ErrorCode.HOI_DONG_NOT_FOUND));
        HoiDong hoiDong = phanCongBaoVe.getHoiDongBaoVe();

        List<PhanCongPhanBien> phanBienList = phanCongPhanBienRepository.findByDeTai_Id(idDeTai);
        List<DiemPhanBien> diemPhanBienList = diemPhanBienRepository.findByPhanCongPhanBien_DeTai_Id(idDeTai);
        List<DiemBaoVeChiTiet> diemBaoVeList = diemBaoVeChiTietRepository.findByDeTai_IdAndHopLeTrue(idDeTai);

        // Tính điểm phản biện (nếu có)
        Double diemPhanBienTB = null;
        if (!phanBienList.isEmpty() && !diemPhanBienList.isEmpty()) {
            diemPhanBienTB = diemPhanBienList.stream()
                    .mapToDouble(d -> d.getDiem() != null ? d.getDiem() : 0.0)
                    .average()
                    .orElse(0.0);
        }

        // Tính điểm hội đồng
        Double diemHoiDongTB = diemBaoVeList.stream()
                .mapToDouble(d -> d.getDiem() != null ? d.getDiem() : 0.0)
                .average()
                .orElse(0.0);

        BaoCao baoCao = baoCaoRepository.findTopByDeTai_IdAndTrangThaiOrderByPhienBanDesc(idDeTai , TrangThaiDuyetDon.DA_DUYET)
                .orElseThrow(() -> new ApplicationException(ErrorCode.BAO_CAO_NOT_FOUND));

        String duongDanBaoCao = baoCao.getDuongDanFile() != null ? baoCao.getDuongDanFile() : null;

        // Điểm báo cáo
        Double diemBaoCao = baoCao.getDiemHuongDan() != null ? baoCao.getDiemHuongDan() : 0.0;

        List<PhanCongPhanBienResponse.GiangVienChamDiem> giangVienList = new ArrayList<>();
        Set<Long> addedGiangVienIds = new HashSet<>(); // Track added IDs


        // Thêm phản biện (nếu có)
        phanBienList.forEach(pcb -> {
            DiemPhanBien diemPB = diemPhanBienList.stream()
                    .filter(d -> d.getPhanCongPhanBien().getId().equals(pcb.getId()))
                    .findFirst()
                    .orElse(null);

            GiangVien gv = pcb.getGiangVien();
            giangVienList.add(PhanCongPhanBienResponse.GiangVienChamDiem.builder()
                    .idGiangVien(gv.getId())
                    .hoTen(gv.getHoTen())
                    .maGiangVien(gv.getMaGiangVien())
                    .vaiTro(pcb.getVaiTro().toString())
                    .idBoMon(gv.getBoMon() != null ? gv.getBoMon().getId().toString() : null)
                    .boMon(gv.getBoMon() != null ? gv.getBoMon().getTenBoMon() : null)
                    .diem(diemPB != null && diemPB.getDiem() != null ? diemPB.getDiem() : null)
                    .nhanXet(diemPB != null ? diemPB.getNhanXet() : null)
                    .trangThai(diemPB != null ? diemPB.getTrangThai().name() : "CHUA_CHAM")
                    .hopLe(null)
                    .build());
            addedGiangVienIds.add(gv.getId());
        });

        // Thêm Chủ tịch
        if (hoiDong.getChuTich() != null) {
            addGiangVienHoiDong(giangVienList, hoiDong.getChuTich(), idDeTai,
                    diemBaoVeList, "CHU_TICH", addedGiangVienIds);
        }

        // Thêm Thư ký
        if (hoiDong.getThuKy() != null) {
            addGiangVienHoiDong(giangVienList, hoiDong.getThuKy(), idDeTai,
                    diemBaoVeList, "THU_KY", addedGiangVienIds);
        }

        // Thêm thành viên hội đồng (chỉ những người chưa được thêm)
        hoiDong.getThanhVienHoiDongSet().forEach(tv -> {
            if (!addedGiangVienIds.contains(tv.getGiangVien().getId())) {
                addGiangVienHoiDong(giangVienList, tv.getGiangVien(), idDeTai,
                        diemBaoVeList, "UY_VIEN", addedGiangVienIds);
            }
        });

        return PhanCongPhanBienResponse.builder()
                .id(deTai.getId())
                .tenHoiDong(hoiDong.getTenHoiDong())
                .ngayBatDau(hoiDong.getThoiGianBatDau())
                .ngayKetThuc(hoiDong.getThoiGianKetThuc())
                .maSinhVien(deTai.getSinhVien().getMaSinhVien())
                .hoTen(deTai.getSinhVien().getHoTen())
                .lop(deTai.getSinhVien().getLop() != null ? deTai.getSinhVien().getLop().getTenLop() : null)
                .idDeTai(deTai.getId().toString())
                .tenDeTai(deTai.getTenDeTai())
                .duongDanBaoCao(duongDanBaoCao)
                .gvhd(deTai.getGiangVienHuongDan() != null ? deTai.getGiangVienHuongDan().getHoTen() : null)
                .idBoMon(deTai.getBoMon() != null ? deTai.getBoMon().getId().toString() : null)
                .boMon(deTai.getBoMon() != null ? deTai.getBoMon().getTenBoMon() : null)
                .diemBaoCao(diemBaoCao)
                .diemPhanBien(diemPhanBienTB != null ? round(diemPhanBienTB, 2) : null)
                .diemHoiDong(round(diemHoiDongTB, 2))
                .giangVien(giangVienList)
                .build();
    }

    private void addGiangVienHoiDong(
            List<PhanCongPhanBienResponse.GiangVienChamDiem> list,
            GiangVien gv,
            Long idDeTai,
            List<DiemBaoVeChiTiet> diemList,
            String vaiTro,
            Set<Long> addedGiangVienIds) {

        if (gv == null || addedGiangVienIds.contains(gv.getId())) {
            return; // Skip if already added
        }

        DiemBaoVeChiTiet diem = diemList.stream()
                .filter(d -> {
                    if (d.getThanhVienHoiDong() == null) return false;
                    return d.getThanhVienHoiDong().getGiangVien() != null &&
                            d.getThanhVienHoiDong().getGiangVien().getId().equals(gv.getId());
                })
                .findFirst()
                .orElse(null);

        list.add(PhanCongPhanBienResponse.GiangVienChamDiem.builder()
                .idGiangVien(gv.getId())
                .hoTen(gv.getHoTen())
                .maGiangVien(gv.getMaGiangVien())
                .vaiTro(vaiTro)
                .idBoMon(gv.getBoMon() != null ? gv.getBoMon().getId().toString() : null)
                .boMon(gv.getBoMon() != null ? gv.getBoMon().getTenBoMon() : null)
                .diem(diem != null ? diem.getDiem() : null)
                .nhanXet(diem != null ? diem.getNhanXet() : null)
                .trangThai(diem != null ? diem.getTrangThai().name() : "CHUA_CHAM")
                .hopLe(diem != null && diem.getHopLe() != null && diem.getHopLe() ? "HOP_LE" : "KHONG_HOP_LE")
                .build());

        addedGiangVienIds.add(gv.getId()); // Mark as added
    }

    private Double round(Double value, int places) {
        if (value == null) return null;
        return Math.round(value * Math.pow(10, places)) / Math.pow(10, places);
    }

    public String postPhanCongPhanBienToSinhVien(PhanCongPhanBienRequest request) {
        // 1. Validate input
        if (request.getLecturers() == null || request.getLecturers().isEmpty()) {
            throw new ApplicationException(ErrorCode.PHAN_BIEN_LECTURER_EMPTY);
        }

        if (request.getLecturers().size() > 2) {
            throw new ApplicationException(ErrorCode.PHAN_BIEN_MAX_2_LECTURERS);
        }

        Long deTaiId;
        try {
            deTaiId = Long.parseLong(request.getIdDeTai());
        } catch (NumberFormatException e) {
            throw new ApplicationException(ErrorCode.INVALID_DE_TAI_ID);
        }

        // 2. Kiểm tra đề tài tồn tại
        DeTai deTai = deTaiRepository.findById(deTaiId)
                .orElseThrow(() -> new ApplicationException(ErrorCode.DE_TAI_NOT_FOUND));

        // 3. Kiểm tra GVPB có phải trùng GVHD không
        Long gvhdId = deTai.getGiangVienHuongDan() != null ? deTai.getGiangVienHuongDan().getId() : null;
        if (gvhdId != null) {
            boolean anyMatches = request.getLecturers().stream()
                    .anyMatch(li -> gvhdId.equals(li.getGiangVienId()));
            if (anyMatches) {
                throw new ApplicationException(ErrorCode.PHAN_BIEN_CANNOT_BE_GVHD);
            }
        }

        // 4. Kiểm tra số lượng phản biện hiện tại
        int currentCount = phanCongPhanBienRepository.countByDeTai_Id(deTaiId);
        if (currentCount >= 2) {
            throw new ApplicationException(ErrorCode.PHAN_BIEN_ALREADY_FULL);
        }

        // 5. Kiểm tra trùng giảng viên trong request
        Set<Long> lecturerIds = request.getLecturers().stream()
                .map(PhanCongPhanBienRequest.LecturerItem::getGiangVienId)
                .collect(Collectors.toSet());
        if (lecturerIds.size() != request.getLecturers().size()) {
            throw new ApplicationException(ErrorCode.DUPLICATE_LECTURER_IN_REQUEST);
        }

        // 6. Kiểm tra trùng với phản biện hiện tại
        List<PhanCongPhanBien> existingPhanBien = phanCongPhanBienRepository.findByDeTai_Id(deTaiId);
        Set<Long> existingIds = existingPhanBien.stream()
                .map(p -> p.getGiangVien().getId())
                .collect(Collectors.toSet());

        for (Long gvId : lecturerIds) {
            if (existingIds.contains(gvId)) {
                throw new ApplicationException(ErrorCode.LECTURER_ALREADY_ASSIGNED_AS_PB);
            }
        }

        // 7. Kiểm tra giảng viên tồn tại
        List<GiangVien> giangViens = giangVienRepository.findAllById(lecturerIds);
        if (giangViens.size() != lecturerIds.size()) {
            throw new ApplicationException(ErrorCode.GIANG_VIEN_NOT_FOUND);
        }

        // 8. Tạo phân công phản biện
        List<PhanCongPhanBien> newPhanBienList = new ArrayList<>();

        int index = currentCount; // Bắt đầu từ vị trí hiện tại (0 hoặc 1)
        for (PhanCongPhanBienRequest.LecturerItem item : request.getLecturers()) {
            GiangVien gv = giangViens.stream()
                    .filter(g -> g.getId().equals(item.getGiangVienId()))
                    .findFirst()
                    .orElseThrow();

           VaiTroPhanBien vaiTro = (index == 0) ? VaiTroPhanBien.PHAN_BIEN_1 : VaiTroPhanBien.PHAN_BIEN_2;

            PhanCongPhanBien phanBien = PhanCongPhanBien.builder()
                    .deTai(deTai)
                    .giangVien(gv)
                    .vaiTro(vaiTro)
                    .build();

            newPhanBienList.add(phanBien);
            index++;
        }

        // 9. Lưu vào DB
        phanCongPhanBienRepository.saveAll(newPhanBienList);

        // 10. Trả về thông báo thành công
        return String.format("Phân công phản biện thành công cho đề tài [%s] - %s phản biện được thêm.",
                deTai.getTenDeTai(), newPhanBienList.size());
    }





    private File generateImportLogExcel(List<ImportLogRow> rows) throws IOException {
        Workbook wb = new XSSFWorkbook();
        Sheet sh = wb.createSheet("Ket qua import");

        Row h = sh.createRow(0);
        h.createCell(0).setCellValue("Mã sinh viên");
        h.createCell(1).setCellValue("Tên đề tài");
        h.createCell(2).setCellValue("Kết quả");
        h.createCell(3).setCellValue("Lý do");

        int r = 1;
        for (ImportLogRow it : rows) {
            Row row = sh.createRow(r++);
            row.createCell(0).setCellValue(it.maSinhVien);
            row.createCell(1).setCellValue(it.tenDeTai);
            row.createCell(2).setCellValue(it.success ? "THÀNH CÔNG" : "THẤT BẠI");
            row.createCell(3).setCellValue(it.success ? "" : (it.reason == null ? "" : it.reason));
        }

        for (int i = 0; i <= 3; i++) sh.autoSizeColumn(i);

        File tmp = File.createTempFile("import-hoidong-log-", ".xlsx");
        try (FileOutputStream os = new FileOutputStream(tmp)) {
            wb.write(os);
        }
        wb.close();
        return tmp;
    }

    private static String norm(String s) {
        if (s == null) return "";
        s = s.replace('\u00A0', ' ');          // NBSP -> space
        s = s.replaceAll("\\s+", " ").trim();  // gộp khoảng trắng
        String n = java.text.Normalizer.normalize(s, java.text.Normalizer.Form.NFD);
        n = n.replaceAll("\\p{M}+", "");       // bỏ dấu
        return n.toLowerCase(java.util.Locale.ROOT);
    }

    private static class ImportLogRow {
        public final String maSinhVien;
        public final String tenDeTai;
        public final boolean success;
        public final String reason; // null/"" nếu success

        ImportLogRow(String maSinhVien, String tenDeTai, boolean success, String reason) {
            this.maSinhVien = maSinhVien;
            this.tenDeTai = tenDeTai;
            this.success = success;
            this.reason = reason;
        }
    }
}
