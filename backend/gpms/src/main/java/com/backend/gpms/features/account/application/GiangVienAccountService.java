package com.backend.gpms.features.account.application;

import com.backend.gpms.features.account.dto.request.*;
import com.backend.gpms.features.account.dto.response.CreatedAccountResponse;
import com.backend.gpms.features.auth.domain.Role;
import com.backend.gpms.features.auth.domain.User;
import com.backend.gpms.features.auth.infra.UserRepository;
import com.backend.gpms.features.department.infra.BoMonRepository;
import com.backend.gpms.features.lecturer.domain.GiangVien;
import com.backend.gpms.features.lecturer.infra.GiangVienRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service @RequiredArgsConstructor
public class GiangVienAccountService {
    private final UserRepository userRepo;
    private final BoMonRepository boMonRepo;
    private final GiangVienRepository gvRepo;
    private final PasswordEncoder encoder;

    @Transactional
    public CreatedAccountResponse register(GiangVienAccountRequest req) {
        if (userRepo.existsByEmail(req.getEmail()))
            throw new IllegalArgumentException("Email đã tồn tại");

        var role = req.getVaiTro();
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

        var gv = GiangVien.builder()
                .hoTen(req.getHoTen())
                .maGiangVien(req.getMaGiangVien())
                .soDienThoai(req.getSoDienThoai())
                .hocHam(req.getHocHam())
                .hocVi(req.getHocVi())
                .idBoMon(boMon)
                .user(user)
                .quotaInstruct(req.getQuotaInstruct())
                .build();
        gv = gvRepo.save(gv);

        return new CreatedAccountResponse(user.getId(), user.getEmail(), user.getVaiTro().name(), gv.getId(), gv.getHoTen());
    }
}
