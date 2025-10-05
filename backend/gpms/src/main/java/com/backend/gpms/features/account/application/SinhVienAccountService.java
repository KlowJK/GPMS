package com.backend.gpms.features.account.application;

import com.backend.gpms.common.util.ApiResponse;
import com.backend.gpms.features.account.dto.response.CreatedAccountResponse;
import com.backend.gpms.features.auth.domain.Role;
import com.backend.gpms.features.auth.domain.User;
import com.backend.gpms.features.auth.infra.UserRepository;
import com.backend.gpms.features.department.infra.LopRepository;
import com.backend.gpms.features.student.domain.SinhVien;
import com.backend.gpms.features.student.dto.request.SinhVienCreateRequest;
import com.backend.gpms.features.student.infra.SinhVienRepository;
import com.backend.gpms.common.mapper.SinhVienMapper;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class SinhVienAccountService {
    private final UserRepository userRepo;
    private final LopRepository lopRepo;
    private final SinhVienRepository svRepo;
    private final PasswordEncoder encoder;
    private final SinhVienMapper mapper;

    @Transactional
    public ApiResponse<CreatedAccountResponse> register(SinhVienCreateRequest req) {
        if (userRepo.existsByEmail(req.getEmail()))
            throw new IllegalArgumentException("Email đã tồn tại");

        var lop = lopRepo.findById(req.getIdLop())
                .orElseThrow(() -> new IllegalArgumentException("Lớp không tồn tại"));

        // 1) Tạo User
        var user = new User();
        user.setEmail(req.getEmail());
        user.setMatKhau(encoder.encode(req.getMatKhau()));
        user.setVaiTro(Role.SINH_VIEN);
        user.setTrangThaiKichHoat(true);
        user = userRepo.save(user);

        // 2) Map -> SinhVien và gắn quan hệ, field còn thiếu
        SinhVien sv = mapper.toSinhVien(req); // nếu có DTO tách riêng

        sv.setSoDienThoai(req.getSoDienThoai());  // <-- fix bug
        sv.setLop(lop);
        sv.setDuDieuKien(Boolean.TRUE);
        sv.setUser(user);

        sv = svRepo.save(sv);

        CreatedAccountResponse response = new CreatedAccountResponse(
                user.getId(), user.getEmail(), user.getVaiTro().name(),
                sv.getId(), sv.getHoTen()
        );
        return ApiResponse.success(response);
    }
}
