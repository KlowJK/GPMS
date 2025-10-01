package com.backend.gpms.features.account.application;

import com.backend.gpms.features.account.dto.response.CreatedAccountResponse;
import com.backend.gpms.features.auth.domain.Role;
import com.backend.gpms.features.auth.domain.User;
import com.backend.gpms.features.auth.infra.UserRepository;
import com.backend.gpms.features.department.infra.BoMonRepository;
import com.backend.gpms.features.lecturer.domain.GiangVien;
import com.backend.gpms.features.lecturer.dto.request.GiangVienCreationRequest;
import com.backend.gpms.features.lecturer.infra.GiangVienRepository;
import com.backend.gpms.common.mapper.GiangVienMapper;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class GiangVienAccountService {
    private final UserRepository userRepo;
    private final BoMonRepository boMonRepo;
    private final GiangVienRepository gvRepo;
    private final PasswordEncoder encoder;
    private final GiangVienMapper mapper;

    @Transactional
    public CreatedAccountResponse register(GiangVienCreationRequest req) {
        if (userRepo.existsByEmail(req.getEmail()))
            throw new IllegalArgumentException("Email đã tồn tại");

        Role role = req.getVaiTro();
        if (role != Role.GIANG_VIEN && role != Role.TRO_LY_KHOA && role != Role.TRUONG_BO_MON)
            throw new IllegalArgumentException("Vai trò không hợp lệ cho giảng viên");

        var boMon = boMonRepo.findById(req.getIdBoMon())
                .orElseThrow(() -> new IllegalArgumentException("Bộ môn không tồn tại"));

        var user = new User();
        user.setEmail(req.getEmail());
        user.setMatKhau(encoder.encode(req.getMatKhau()));
        user.setVaiTro(role);
        user.setTrangThaiKichHoat(true);
        user = userRepo.save(user);

        GiangVien gv = mapper.toGiangVien(req); // nếu bạn dùng 1 DTO khác, map trực tiếp từ req cũng được

        gv.setIdBoMon(boMon);
        gv.setUser(user);
        gv.setQuotaInstruct(req.getQuotaInstruct() == null ? 0 : req.getQuotaInstruct());
        gv = gvRepo.save(gv);

        return new CreatedAccountResponse(
                user.getId(), user.getEmail(), user.getVaiTro().name(),
                gv.getId(), gv.getHoTen()
        );
    }
}
