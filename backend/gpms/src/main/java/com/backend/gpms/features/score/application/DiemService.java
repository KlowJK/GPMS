package com.backend.gpms.features.score.application;

import com.backend.gpms.common.exception.ApplicationException;
import com.backend.gpms.common.exception.ErrorCode;
import com.backend.gpms.features.council.domain.HoiDong;
import com.backend.gpms.features.council.domain.PhanCongBaoVe;
import com.backend.gpms.features.council.domain.PhanCongPhanBien;
import com.backend.gpms.features.council.domain.ThanhVienHoiDong;
import com.backend.gpms.features.council.infra.PhanCongBaoVeRepository;
import com.backend.gpms.features.council.infra.PhanCongPhanBienRepository;
import com.backend.gpms.features.lecturer.domain.GiangVien;
import com.backend.gpms.features.lecturer.infra.GiangVienRepository;
import com.backend.gpms.features.score.domain.Diem;
import com.backend.gpms.features.score.domain.DiemBaoVeChiTiet;
import com.backend.gpms.features.score.domain.DiemPhanBien;
import com.backend.gpms.features.score.domain.TrangThaiDiem;
import com.backend.gpms.features.score.dto.request.DiemRequest;
import com.backend.gpms.features.score.infra.DiemBaoVeChiTietRepository;
import com.backend.gpms.features.score.infra.DiemPhanBienRepository;
import com.backend.gpms.features.score.infra.DiemRepository;
import com.backend.gpms.features.topic.domain.DeTai;
import com.backend.gpms.features.topic.infra.DeTaiRepository;
import jakarta.transaction.Transactional;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;


@Service
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
@RequiredArgsConstructor
@Transactional
public class DiemService    {

    GiangVienRepository giangVienRepository;
    DeTaiRepository deTaiRepository;
    PhanCongPhanBienRepository phanCongPhanBienRepository;
    PhanCongBaoVeRepository phanCongBaoVeRepository;
    DiemPhanBienRepository diemPhanBienRepository;
    DiemBaoVeChiTietRepository diemBaoVeChiTietRepository;
    DiemRepository diemRepository;

    public String nhapDiemChung(DiemRequest request) {
        String email = getCurrentUsername();
        GiangVien gv = giangVienRepository.findByUser_Email(email)
                .orElseThrow(() -> new ApplicationException(ErrorCode.GIANG_VIEN_NOT_FOUND));

        DeTai deTai = deTaiRepository.findById(request.getIdDeTai())
                .orElseThrow(() -> new ApplicationException(ErrorCode.DE_TAI_NOT_FOUND));

        // Kiểm tra quyền: GV phải là phản biện HOẶC thành viên hội đồng của đề tài
        boolean isPhanBien = phanCongPhanBienRepository.existsByDeTai_IdAndGiangVien_Id(
                deTai.getId(), gv.getId());

        boolean isThanhVienHoiDong = false;
        Optional<PhanCongBaoVe> phanCongBaoVeOpt = phanCongBaoVeRepository.findByDeTai_Id(deTai.getId());
        if (phanCongBaoVeOpt.isPresent()) {
            HoiDong hoiDong = phanCongBaoVeOpt.get().getHoiDongBaoVe();
            isThanhVienHoiDong =
                    hoiDong.getChuTich() != null && hoiDong.getChuTich().getId().equals(gv.getId()) ||
                            hoiDong.getThuKy() != null && hoiDong.getThuKy().getId().equals(gv.getId()) ||
                            hoiDong.getThanhVienHoiDongSet().stream()
                                    .anyMatch(tv -> tv.getGiangVien().getId().equals(gv.getId()));
        }

        if (!isPhanBien && !isThanhVienHoiDong) {
            throw new ApplicationException(ErrorCode.UNAUTHORIZED_NHAP_DIEM);
        }

        // === NHẬP ĐIỂM PHẢN BIỆN ===
        if (isPhanBien) {
            PhanCongPhanBien phanBien = phanCongPhanBienRepository
                    .findByDeTai_IdAndGiangVien_Id(deTai.getId(), gv.getId())
                    .orElseThrow(() -> new ApplicationException(ErrorCode.PHAN_BIEN_NOT_FOUND));

            // Kiểm tra đã chấm chưa
            Optional<DiemPhanBien> existingDiem = diemPhanBienRepository
                    .findByPhanCongPhanBien_Id(phanBien.getId());

            DiemPhanBien diemPhanBien;
            if (existingDiem.isPresent()) {
                diemPhanBien = existingDiem.get();
                diemPhanBien.setDiem(request.getDiem());
                diemPhanBien.setNhanXet(request.getNhanXet());
                diemPhanBien.setTrangThai(TrangThaiDiem.CHO_PHE_DUYET);
            } else {
                diemPhanBien = DiemPhanBien.builder()
                        .phanCongPhanBien(phanBien)
                        .diem(request.getDiem())
                        .nhanXet(request.getNhanXet())
                        .trangThai(TrangThaiDiem.CHO_PHE_DUYET)
                        .build();
            }

            diemPhanBienRepository.save(diemPhanBien);

            // Cập nhật tổng hợp điểm phản biện (nếu đủ 2 người)
            capNhatDiemPhanBienTongHop(deTai.getId());

            return String.format("Nhập điểm phản biện thành công cho đề tài [%s] - Điểm: %.2f",
                    deTai.getTenDeTai(), request.getDiem());
        }

        // === NHẬP ĐIỂM BẢO VỆ (HỘI ĐỒNG) ===
        if (isThanhVienHoiDong) {
            ThanhVienHoiDong thanhVien = null;
            HoiDong hoiDong = phanCongBaoVeOpt.get().getHoiDongBaoVe();

            // Tìm ThanhVienHoiDong tương ứng
            if (hoiDong.getChuTich() != null && hoiDong.getChuTich().getId().equals(gv.getId())) {
                // Chủ tịch không có trong thanhVienHoiDongSet → xử lý riêng
            } else if (hoiDong.getThuKy() != null && hoiDong.getThuKy().getId().equals(gv.getId())) {
                // Thư ký
            } else {
                thanhVien = hoiDong.getThanhVienHoiDongSet().stream()
                        .filter(tv -> tv.getGiangVien().getId().equals(gv.getId()))
                        .findFirst()
                        .orElseThrow(() -> new ApplicationException(ErrorCode.THANH_VIEN_HOI_DONG_NOT_FOUND));
            }

            // Kiểm tra đã chấm chưa
            Optional<DiemBaoVeChiTiet> existingDiem = diemBaoVeChiTietRepository
                    .findByDeTai_IdAndThanhVienHoiDong_GiangVien_Id(deTai.getId(), gv.getId());

            DiemBaoVeChiTiet diemBaoVe;
            if (existingDiem.isPresent()) {
                diemBaoVe = existingDiem.get();
                diemBaoVe.setDiem(request.getDiem());
                diemBaoVe.setNhanXet(request.getNhanXet());
                diemBaoVe.setTrangThai(TrangThaiDiem.CHO_PHE_DUYET);
                diemBaoVe.setHopLe(true); // mặc định hợp lệ
            } else {
                diemBaoVe = DiemBaoVeChiTiet.builder()
                        .deTai(deTai)
                        .thanhVienHoiDong(thanhVien)
                        .diem(request.getDiem())
                        .nhanXet(request.getNhanXet())
                        .trangThai(TrangThaiDiem.CHO_PHE_DUYET)
                        .hopLe(true)
                        .build();
            }

            diemBaoVeChiTietRepository.save(diemBaoVe);

            // Cập nhật điểm hội đồng tổng hợp
            capNhatDiemHoiDongTongHop(deTai.getId());

            return String.format("Nhập điểm bảo vệ thành công cho đề tài [%s] - Điểm: %.2f",
                    deTai.getTenDeTai(), request.getDiem());
        }

        throw new ApplicationException(ErrorCode.UNAUTHORIZED_NHAP_DIEM);
    }

    private void capNhatDiemPhanBienTongHop(Long deTaiId) {
        List<DiemPhanBien> diemList = diemPhanBienRepository.findByPhanCongPhanBien_DeTai_Id(deTaiId);
        if (diemList.size() != 2) return;

        Double avg = diemList.stream()
                .mapToDouble(d -> d.getDiem() != null ? d.getDiem() : 0.0)
                .average()
                .orElse(0.0);

        Diem diemTong = diemRepository.findByDeTai_Id(deTaiId)
                .orElseGet(() -> Diem.builder().deTai(deTaiRepository.getReferenceById(deTaiId)).build());

        diemTong.setDiemPhanBien(avg);
        if (avg >= 5.5) {
            diemTong.setTrangThai(TrangThaiDiem.CHO_PHE_DUYET);
        }
        diemRepository.save(diemTong);
        capNhatDiemTongHop(deTaiId);
    }

    private void capNhatDiemHoiDongTongHop(Long deTaiId) {
        List<DiemBaoVeChiTiet> diemList = diemBaoVeChiTietRepository
                .findByDeTai_IdAndHopLeTrue(deTaiId);

        // Giả sử cần 5 điểm
        if (diemList.size() < 5) return;

        Double avg = diemList.stream()
                .mapToDouble(d -> d.getDiem() != null ? d.getDiem() : 0.0)
                .average()
                .orElse(0.0);

        Diem diemTong = diemRepository.findByDeTai_Id(deTaiId)
                .orElseGet(() -> Diem.builder().deTai(deTaiRepository.getReferenceById(deTaiId)).build());

        diemTong.setDiemBaoVe(avg);
        diemTong.setTrangThai(TrangThaiDiem.CHO_PHE_DUYET);
        diemRepository.save(diemTong);
        capNhatDiemTongHop(deTaiId);
    }

    void capNhatDiemTongHop(Long deTaiId) {
        Diem diemTong = diemRepository.findByDeTai_Id(deTaiId)
                .orElseGet(() -> Diem.builder().deTai(deTaiRepository.getReferenceById(deTaiId)).build());

        Double diemBaoCao = diemTong.getDiemBaoCao() != null ? diemTong.getDiemBaoCao() : 0.0;
        Double diemPhanBien = diemTong.getDiemPhanBien() != null ? diemTong.getDiemPhanBien() : 0.0;
        Double diemBaoVe = diemTong.getDiemBaoVe() != null ? diemTong.getDiemBaoVe() : 0.0;

        if (diemPhanBien > 0 && diemBaoVe > 0 && diemBaoCao > 0) {
            Double avg = 0.3 * diemBaoCao + 0.3 * diemPhanBien + 0.4 * diemBaoVe;
            diemTong.setDiemTong(avg);
            diemRepository.save(diemTong);
        }
    }

    public String pheDuyetDiemChung(Long deTaiId) {
        // 1. Lấy đề tài
        DeTai deTai = deTaiRepository.findById(deTaiId)
                .orElseThrow(() -> new ApplicationException(ErrorCode.DE_TAI_NOT_FOUND));

        // 2. Lấy điểm tổng hợp
        Diem diemTong = diemRepository.findByDeTai_Id(deTaiId)
                .orElseGet(() -> Diem.builder()
                        .deTai(deTai)
                        .trangThai(TrangThaiDiem.CHO_PHE_DUYET)
                        .build());

        // 3. Lấy điểm phản biện
        List<DiemPhanBien> diemPhanBienList = diemPhanBienRepository
                .findByPhanCongPhanBien_DeTai_Id(deTaiId);

        // 4. Lấy điểm bảo vệ (chỉ điểm hợp lệ)
        List<DiemBaoVeChiTiet> diemBaoVeList = diemBaoVeChiTietRepository
                .findByDeTai_IdAndHopLeTrue(deTaiId);

        // 5. Kiểm tra đủ điểm và trạng thái
        if (diemPhanBienList.size() != 2) {
            throw new ApplicationException(ErrorCode.PHAN_BIEN_CHUA_DU);
        }

        if (diemBaoVeList.size() < 5) {
            throw new ApplicationException(ErrorCode.HOI_DONG_CHUA_DU);
        }

        // Kiểm tra tất cả điểm phản biện ở trạng thái CHO_PHE_DUYET
        boolean allPhanBienReady = diemPhanBienList.stream()
                .allMatch(d -> TrangThaiDiem.CHO_PHE_DUYET.equals(d.getTrangThai()));
        if (!allPhanBienReady) {
            throw new ApplicationException(ErrorCode.PHAN_BIEN_CHUA_SANSANG_PHE_DUYET);
        }

        // Kiểm tra tất cả điểm bảo vệ ở trạng thái CHO_PHE_DUYET
        boolean allBaoVeReady = diemBaoVeList.stream()
                .allMatch(d -> TrangThaiDiem.CHO_PHE_DUYET.equals(d.getTrangThai()));
        if (!allBaoVeReady) {
            throw new ApplicationException(ErrorCode.HOI_DONG_CHUA_SANSANG_PHE_DUYET);
        }

        // 6. Tính trung bình điểm phản biện
        Double diemPhanBienTB = diemPhanBienList.stream()
                .mapToDouble(d -> d.getDiem() != null ? d.getDiem() : 0.0)
                .average()
                .orElse(0.0);

        if (diemPhanBienTB < 5.5) {
            throw new ApplicationException(ErrorCode.DIEM_PHAN_BIEN_KHONG_DAT);
        }

        // 7. Tính trung bình điểm hội đồng
        Double diemHoiDongTB = diemBaoVeList.stream()
                .mapToDouble(d -> d.getDiem() != null ? d.getDiem() : 0.0)
                .average()
                .orElse(0.0);

        if (diemHoiDongTB < 5.0) {
            throw new ApplicationException(ErrorCode.DIEM_HOI_DONG_KHONG_DAT);
        }

        // 8. Cập nhật điểm tổng hợp
        diemTong.setDiemPhanBien(round(diemPhanBienTB, 2));
        diemTong.setDiemBaoVe(round(diemHoiDongTB, 2));
        Double diemBaoCao = diemTong.getDiemBaoCao() != null ? diemTong.getDiemBaoCao() : 0.0;

        // (Tùy chọn) Tính điểm tổng = trọng số
         diemTong.setDiemTong(0.3 * diemBaoCao + 0.3 * diemPhanBienTB + 0.4 * diemHoiDongTB);

        diemTong.setTrangThai(TrangThaiDiem.DA_PHE_DUYET);
        diemRepository.save(diemTong);

        // 9. Cập nhật trạng thái điểm chi tiết (từ CHO_PHE_DUYET → DA_PHE_DUYET)
        diemPhanBienList.forEach(d -> {
            d.setTrangThai(TrangThaiDiem.DA_PHE_DUYET);
            diemPhanBienRepository.save(d);
        });

        diemBaoVeList.forEach(d -> {
            d.setTrangThai(TrangThaiDiem.DA_PHE_DUYET);
            diemBaoVeChiTietRepository.save(d);
        });

        // 10. Trả về thông báo
        return String.format(
                "Phê duyệt điểm thành công cho đề tài [%s]. " +
                        "Phản biện: %.2f | Hội đồng: %.2f | Tổng hợp: ĐÃ PHÊ DUYỆT",
                deTai.getTenDeTai(), diemPhanBienTB, diemHoiDongTB
        );
    }

    private Double round(Double value, int places) {
        if (value == null) return null;
        return Math.round(value * Math.pow(10, places)) / Math.pow(10, places);
    }

    private String getCurrentUsername() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        try { return auth.getName(); }
        catch (Exception e) { throw new ApplicationException(ErrorCode.UNAUTHENTICATED); }
    }

}


