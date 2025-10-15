package com.backend.gpms.features.notification.application;

import com.backend.gpms.common.exception.ApplicationException;
import com.backend.gpms.common.exception.ErrorCode;
import com.backend.gpms.common.mapper.ThongBaoMapper;
import com.backend.gpms.features.auth.domain.User;
import com.backend.gpms.features.auth.infra.UserRepository;
import com.backend.gpms.features.notification.domain.LoaiThongBao;
import com.backend.gpms.features.notification.domain.ThongBao;
import com.backend.gpms.features.notification.domain.ThongBaoDen;
import com.backend.gpms.features.notification.dto.request.ThongBaoRequest;
import com.backend.gpms.features.notification.dto.response.ThongBaoResponse;
import com.backend.gpms.features.notification.infra.ThongBaoDenRepository;
import com.backend.gpms.features.notification.infra.ThongBaoRepository;
import com.backend.gpms.features.storage.application.CloudinaryStorageService;
import jakarta.transaction.Transactional;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.time.OffsetDateTime;
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

    private String currentUsername() {
        return SecurityContextHolder.getContext().getAuthentication().getName();
    }
}