package com.backend.gpms.features.account.application;

import com.backend.gpms.features.account.dto.request.*;
import com.backend.gpms.features.account.dto.response.CreatedAccountResponse;
import com.backend.gpms.features.auth.domain.Role;
import com.backend.gpms.features.auth.domain.User;
import com.backend.gpms.features.auth.infra.UserRepository;
import com.backend.gpms.features.department.infra.LopRepository;
import com.backend.gpms.features.student.domain.SinhVien;
import com.backend.gpms.features.student.infra.SinhVienRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;


@Service @RequiredArgsConstructor
public class SinhVienAccountService {
    private final UserRepository userRepo;
    private final LopRepository lopRepo;
    private final SinhVienRepository svRepo;
    private final PasswordEncoder encoder;

    @Transactional
    public CreatedAccountResponse register(SinhVienAccountRequest req) {
        if (userRepo.existsByEmail(req.getEmail()))
            throw new IllegalArgumentException("Email đã tồn tại");

        var lop = lopRepo.findById(req.getIdLop())
                .orElseThrow(() -> new IllegalArgumentException("Lớp không tồn tại"));

        var user = new User();
        user.setEmail(req.getEmail());
        user.setMatKhau(encoder.encode(req.getMatKhau()));
        user.setVaiTro(Role.SINH_VIEN);
        user.setTrangThaiKichHoat(true);
        user = userRepo.save(user);

        var sv = new SinhVien();
        sv.setHoTen(req.getHoTen());
        sv.setMaSinhVien(req.getMaSinhVien());
        sv.setSoDienThoai(req.getMaSinhVien());
        sv.setIdLop(lop);
        sv.setDuDieuKien(Boolean.TRUE.equals(req.getDuDieuKien()));
        sv.setUser(user);
        sv = svRepo.save(sv);

        return new CreatedAccountResponse(user.getId(), user.getEmail(), user.getVaiTro().name(), sv.getId(), sv.getHoTen());
    }
}
