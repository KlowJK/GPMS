package com.backend.gpms.features.notification.application;

import com.backend.gpms.common.exception.ApplicationException;
import com.backend.gpms.common.exception.ErrorCode;
import com.backend.gpms.common.mapper.ThongBaoMapper;
import com.backend.gpms.features.auth.application.EmailService;
import com.backend.gpms.features.auth.domain.User;
import com.backend.gpms.features.auth.infra.UserRepository;
import com.backend.gpms.features.council.domain.HoiDong;
import com.backend.gpms.features.council.domain.ThanhVienHoiDong;
import com.backend.gpms.features.council.infra.HoiDongRepository;
import com.backend.gpms.features.defense.domain.ThoiGianThucHien;
import com.backend.gpms.features.defense.infra.DotBaoVeRepository;
import com.backend.gpms.features.defense.infra.ThoiGianThucHienRepository;
import com.backend.gpms.features.notification.domain.LoaiThongBao;
import com.backend.gpms.features.notification.domain.ThongBao;
import com.backend.gpms.features.notification.domain.ThongBaoDen;
import com.backend.gpms.features.notification.dto.request.ThongBaoRequest;
import com.backend.gpms.features.notification.dto.response.ThongBaoResponse;
import com.backend.gpms.features.notification.infra.ThongBaoDenRepository;
import com.backend.gpms.features.notification.infra.ThongBaoRepository;
import com.backend.gpms.features.storage.application.CloudinaryStorageService;
import com.backend.gpms.features.topic.domain.DeTai;
import com.backend.gpms.features.topic.infra.DeTaiRepository;
import jakarta.transaction.Transactional;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.Stream;


@Service
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@RequiredArgsConstructor
@Transactional
public class ThongBaoService{

    ThongBaoRepository thongBaoRepository;
    ThongBaoMapper thongBaoMapper;
    CloudinaryStorageService cloudinaryService;
    UserRepository userRepository;
    ThongBaoDenRepository thongBaoDenRepository;
    DeTaiRepository deTaiRepository;
    EmailService emailService;
    ThoiGianThucHienRepository thoiGianThucHienRepository;
    HoiDongRepository hoiDongRepository;

    ZoneId ZONE_VN = ZoneId.of("Asia/Ho_Chi_Minh");


    @Scheduled(cron = "0 0 7 * * ?", zone = "Asia/Ho_Chi_Minh")
    @Transactional
    public void guiThongBaoTuDong() {
        LocalDate today = LocalDate.now(ZONE_VN);
        LocalDate tomorrow = today.plusDays(1);

        guiNhacDeadlineCongViec(today, tomorrow);
        guiLichBaoVe(tomorrow);
    }

    public ThongBaoResponse createThongBao(ThongBaoRequest thongBaoRequest) {
        // Xử lý file upload nếu có
        String fileUrl = null;
        if (thongBaoRequest.getFile() != null) {
            fileUrl = cloudinaryService.uploadRawFile(thongBaoRequest.getFile());
        }

        // Tạo và lưu thông báo
        ThongBao thongBao = thongBaoMapper.toThongBao(thongBaoRequest);
        thongBao.setFile(fileUrl);
        thongBao.setThoiGianGui(OffsetDateTime.now()); // Đảm bảo thời gian gửi
        ThongBao savedThongBao = thongBaoRepository.save(thongBao);


        if (thongBaoRequest.getKieuNguoiNhan() != 0) {
            Long khoaId = thongBaoRequest.getKieuNguoiNhan();
            List<User> users = userRepository.findAllTaiKhoanSinhVienAndGiangVienByKhoaId(khoaId);

            if (users.isEmpty()) {
                throw new ApplicationException(ErrorCode.USER_NOT_FOUND);
            }

            // Chỉ tạo ThongBaoDen cho user có id hợp lệ
            List<ThongBaoDen> thongBaoDens = users.stream()
                    .filter(user -> user.getId() != null)
                    .map(user -> {
                        ThongBaoDen thongBaoDen = new ThongBaoDen();
                        thongBaoDen.setThongBao(savedThongBao);
                        thongBaoDen.setUser(user);
                        return thongBaoDen;
                    })
                    .collect(Collectors.toList());

            if (thongBaoDens.isEmpty()) {
                throw new ApplicationException(ErrorCode.USER_NOT_FOUND);
            }

            thongBaoDenRepository.saveAll(thongBaoDens);
        }

        return thongBaoMapper.toThongBaoResponse(savedThongBao);
    }


    public List<ThongBaoResponse> getAllThongBaoList() {
        List<ThongBao> thongBaos = thongBaoRepository.findByLoaiThongBaoOrderByCreatedAtDesc(LoaiThongBao.TRUONG);
        return thongBaos.stream()
                .map(thongBaoMapper::toThongBaoResponse)
                .collect(Collectors.toList());
    }

    public List<ThongBaoResponse> getAllThongBaoListByUser() {
        // Lấy email người dùng hiện tại
        String email = currentUsername();
        Optional<User> user = userRepository.findByEmail(email);
        if (user.isEmpty()) {
            throw new ApplicationException(ErrorCode.UNAUTHENTICATED);
        }

        // Lấy thông báo toàn trường
        List<ThongBao> thongBaoTruong = thongBaoRepository
                .findByLoaiThongBaoOrderByCreatedAtDesc(LoaiThongBao.TRUONG);

        // Lấy thông báo dành riêng cho user qua ThongBaoDen
        List<ThongBao> thongBaoDenUser = thongBaoRepository
                .findByThongBaoDens_User_IdOrderByCreatedAtDesc(user.get().getId());

        // Gộp danh sách, loại bỏ trùng lặp, sắp xếp theo createdAt giảm dần
        List<ThongBao> allThongBaos = Stream.concat(
                        thongBaoTruong.stream(),
                        thongBaoDenUser.stream()
                )
                .distinct() // Loại bỏ trùng lặp dựa trên ThongBao.id
                .sorted((tb1, tb2) -> tb2.getCreatedAt().compareTo(tb1.getCreatedAt())) // Sắp xếp giảm dần
                .collect(Collectors.toList());

        // Chuyển đổi sang ThongBaoResponse
        return allThongBaos.stream()
                .map(thongBaoMapper::toThongBaoResponse)
                .collect(Collectors.toList());
    }

    public Page<ThongBaoResponse> getAllThongBao(Pageable pageable) {
        Page<ThongBao> thongBao = thongBaoRepository.findAll(pageable);
        return thongBao.map(thongBaoMapper::toThongBaoResponse);
    }


    public ThongBaoResponse getThongBaoById(Long id) {

        ThongBao thongBao = thongBaoRepository.findById(id)
                .orElseThrow(() -> new ApplicationException(ErrorCode.THONG_BAO_NOT_FOUND));
        return thongBaoMapper.toThongBaoResponse(thongBao);
    }

    // Nhắc deadline công việc (1 ngày trước)
    private void guiNhacDeadlineCongViec(LocalDate today, LocalDate tomorrow) {
        List<ThoiGianThucHien> deadlines = thoiGianThucHienRepository
                .findByThoiGianKetThucIn(List.of(today, tomorrow));

        for (ThoiGianThucHien tg : deadlines) {
            List<User> recipients = new ArrayList<>();

            // Lấy tất cả sinh viên có đề tài trong đợt
            List<DeTai> deTais = deTaiRepository.findByDotBaoVe(tg.getDotBaoVe());
            for (DeTai dt : deTais) {
                if (dt.getSinhVien() != null && dt.getSinhVien().getUser() != null) {
                    recipients.add(dt.getSinhVien().getUser());
                }
                if (dt.getGiangVienHuongDan() != null && dt.getGiangVienHuongDan().getUser() != null) {
                    recipients.add(dt.getGiangVienHuongDan().getUser());
                }
            }

            if (recipients.isEmpty()) continue;

            String tieuDe = "[NHẮC] Deadline: %s - %s".formatted(
                    tg.getCongViec(), tg.getThoiGianKetThuc());

            String noiDung = """
                    <p><strong>Thông báo deadline quan trọng</strong></p>
                    <p>Công việc: <strong>%s</strong></p>
                    <p>Hạn chót: <strong>%s</strong></p>
                    <p>Đợt bảo vệ: <strong>%s - %s %s</strong></p>
                    <p>Vui lòng hoàn thành đúng hạn để tránh ảnh hưởng tiến độ đồ án.</p>
                    """.formatted(
                    tg.getCongViec(),
                    tg.getThoiGianKetThuc().format(DateTimeFormatter.ofPattern("dd/MM/yyyy")),
                    tg.getDotBaoVe().getTenDot(),
                    tg.getDotBaoVe().getNamHoc(),
                    tg.getDotBaoVe().getHocKi()
            );

            guiThongBaoVaEmail(recipients, tieuDe, noiDung, LoaiThongBao.NHAC_DEADLINE, null);
        }
    }

    // Nhắc lịch bảo vệ (1 ngày trước)
    private void guiLichBaoVe(LocalDate tomorrow) {
        List<HoiDong> hoiDongs = hoiDongRepository.findByThoiGianBatDau(tomorrow);

        for (HoiDong hd : hoiDongs) {
            List<User> recipients = new ArrayList<>();

            // 1. Sinh viên
            for (DeTai dt : hd.getDeTaiSet()) {
                if (dt.getSinhVien() != null && dt.getSinhVien().getUser() != null) {
                    recipients.add(dt.getSinhVien().getUser());
                }
            }

            // 2. Chủ tịch, thư ký
            if (hd.getChuTich() != null && hd.getChuTich().getUser() != null) {
                recipients.add(hd.getChuTich().getUser());
            }
            if (hd.getThuKy() != null && hd.getThuKy().getUser() != null) {
                recipients.add(hd.getThuKy().getUser());
            }

            // 3. Thành viên hội đồng
            for (ThanhVienHoiDong tv : hd.getThanhVienHoiDongSet()) {
                if (tv.getGiangVien() != null && tv.getGiangVien().getUser() != null) {
                    recipients.add(tv.getGiangVien().getUser());
                }
            }

            // Loại trùng
            recipients = recipients.stream().distinct().toList();

            if (recipients.isEmpty()) continue;

            String thoiGian = hd.getThoiGianBatDau().format(DateTimeFormatter.ofPattern("HH:mm")) +
                    " - " + hd.getThoiGianKetThuc().format(DateTimeFormatter.ofPattern("HH:mm"));

            String tieuDe = "[LỊCH] Bảo vệ đồ án - %s".formatted(
                    hd.getThoiGianBatDau().format(DateTimeFormatter.ofPattern("dd/MM/yyyy")));

            String noiDung = """
                    <p><strong>THÔNG BÁO LỊCH BẢO VỆ</strong></p>
                    <p><strong>Hội đồng:</strong> %s</p>
                    <p><strong>Thời gian:</strong> %s ngày <strong>%s</strong></p>
                    <p><strong>Địa điểm:</strong> %s</p>
                    <p><strong>Danh sách đề tài:</strong></p>
                    <ul>
                    %s
                    </ul>
                    <p>Vui lòng có mặt đúng giờ. Liên hệ quản trị nếu có thay đổi.</p>
                    """.formatted(
                    hd.getTenHoiDong(),
                    thoiGian,
                    hd.getThoiGianBatDau().format(DateTimeFormatter.ofPattern("dd/MM/yyyy")),
                    hd.getDiaDiem() != null ? hd.getDiaDiem() : "Chưa xác định",
                    hd.getDeTaiSet().stream()
                            .map(dt -> "<li>%s - %s</li>".formatted(dt.getTenDeTai(), dt.getSinhVien().getHoTen()))
                            .collect(Collectors.joining())
            );

            guiThongBaoVaEmail(recipients, tieuDe, noiDung, LoaiThongBao.LICH_BAO_VE, null);
        }
    }

    // Gửi email + lưu DB
    private void guiThongBaoVaEmail(List<User> users, String tieuDe, String noiDung,
                                    LoaiThongBao loai, String file) {
        // Tạo thông báo chung
        ThongBao thongBao = new ThongBao();
        thongBao.setTieuDe(tieuDe);
        thongBao.setNoiDung(noiDung);
        thongBao.setLoaiThongBao(loai);
        thongBao.setFile(file);
        thongBao.setThoiGianGui(OffsetDateTime.now(ZoneOffset.UTC));
        thongBao = thongBaoRepository.save(thongBao);

        // Gửi email + lưu ThongBaoDen
        for (User user : users) {
            if (user.getEmail() != null && !user.getEmail().isBlank()) {
                try {
                    emailService.sendHtmlEmail(
                            user.getEmail(),
                            tieuDe,
                            noiDung.replace("%s", user.getEmail() != null ? user.getEmail() : "người dùng")
                    );
                } catch (Exception e) {

                }
            }

            // Lưu vào ThongBaoDen
            ThongBaoDen den = new ThongBaoDen();
            den.setThongBao(thongBao);
            den.setUser(user);
            thongBaoDenRepository.save(den);
        }

    }








    private String currentUsername() {
        return SecurityContextHolder.getContext().getAuthentication().getName();
    }
}