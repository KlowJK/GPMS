package com.backend.gpms.features.auth.application;

import com.backend.gpms.common.security.JwtUtils;
import com.backend.gpms.features.auth.domain.User;
import com.backend.gpms.features.auth.dto.request.LoginRequest;
import com.backend.gpms.features.auth.dto.request.RegisterRequest;
import com.backend.gpms.features.auth.dto.response.AuthResponse;
import com.backend.gpms.features.auth.dto.response.UserResponse;
import com.backend.gpms.features.auth.infra.UserRepository;
import com.backend.gpms.features.lecturer.infra.GiangVienRepository;
import com.backend.gpms.features.student.infra.SinhVienRepository;
import org.springframework.security.authentication.*;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;



import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class AuthService {
    private final UserRepository usersRepo;
    private final PasswordEncoder encoder;
    private final AuthenticationManager authManager;
    private final JwtUtils jwt;
    private final SinhVienRepository studentRepo;
    private final GiangVienRepository lecturerRepo;

    public AuthService(UserRepository usersRepo, PasswordEncoder encoder,
                       AuthenticationManager authManager, JwtUtils jwt, SinhVienRepository studentRepo, GiangVienRepository lecturerRepo) {
        this.usersRepo = usersRepo; this.encoder = encoder; this.authManager = authManager; this.jwt = jwt; this.studentRepo = studentRepo; this.lecturerRepo = lecturerRepo;
    }

    @Transactional
    public UserResponse register(RegisterRequest req) {
        if (usersRepo.existsByEmail(req.getEmail()))
            throw new IllegalArgumentException("Email đã tồn tại");

        User user = new User();
        user.setEmail(req.getEmail());
        user.setMatKhau(encoder.encode(req.getMatKhau()));

        user.setVaiTro(req.getVaiTro());
        user = usersRepo.save(user);

        return new UserResponse(user.getId(), user.getEmail(),
                user.getVaiTro(),user.getTrangThaiKichHoat());
    }

    public AuthResponse login(LoginRequest req) {
        Authentication auth = authManager.authenticate(
                new UsernamePasswordAuthenticationToken(req.getEmail(), req.getMatKhau()));

        var principal = (org.springframework.security.core.userdetails.User) auth.getPrincipal();

        // 2) Tải domain user + roles
        var domainUser = usersRepo.findByEmail(principal.getUsername()).orElseThrow();




        List<String> roles = principal.getAuthorities()
                .stream().map(a -> a.getAuthority()).collect(Collectors.toList());

        // 3) Gộp thông tin từ bảng SV/GV (nếu có)
        Long studentId = null, teacherId = null;
        String fullName = null, avt = null;

        var sv = studentRepo.findByUserId(domainUser.getId());
        if (sv.isPresent()) {
            studentId = sv.get().getId();
            fullName  = sv.get().getHoTen();

        }

        var gv = lecturerRepo.findByUserId(domainUser.getId());
        if (gv.isPresent()) {
            teacherId = gv.get().getId();
            // Ưu tiên tên giảng viên nếu có
            fullName  = gv.get().getHoTen() != null ? gv.get().getHoTen() : fullName;

        }

        // 4) Tạo JWT + hạn
        String token = jwt.generate(
                principal.getUsername(),
                Map.of("roles", roles)
        );
        long expiresAt = jwt.getExpiryEpochMillis(token);

        // 5) Build UserResponse
        var userResp = UserResponse.of(
                domainUser.getId(),
                fullName,
                domainUser.getEmail(),
                domainUser.getVaiTro(),
                domainUser.getDuongDanAvt(),
                domainUser.getTrangThaiKichHoat(),
                teacherId,
                studentId
        );
        userResp.setDuongDanAvt(avt);

        // 6) Trả AuthResponse đầy đủ
        return AuthResponse.of(token, expiresAt, userResp);
    }

    public UserResponse me(String email) {
        var user = usersRepo.findByEmail(email).orElseThrow();

        Long studentId = null, teacherId = null;
        String fullName = null, avt = null;

        var sv = studentRepo.findByUserId(user.getId());
        if (sv.isPresent()) {
            studentId = sv.get().getId();
            fullName  = sv.get().getHoTen();

        }
        var gv = lecturerRepo.findByUserId(user.getId());
        if (gv.isPresent()) {
            teacherId = gv.get().getId();
            fullName  = gv.get().getHoTen() != null ? gv.get().getHoTen() : fullName;

        }

        var resp = UserResponse.of(
                user.getId(), fullName, user.getEmail(),
                user.getVaiTro(),user.getDuongDanAvt(), user.getTrangThaiKichHoat(),
                teacherId, studentId
        );
        resp.setDuongDanAvt(avt);
        return resp;
    }
}
