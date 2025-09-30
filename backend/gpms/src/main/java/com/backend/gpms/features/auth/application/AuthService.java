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
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.*;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository usersRepo;
    private final PasswordEncoder encoder;
    private final AuthenticationManager authManager;
    private final JwtUtils jwt;
    private final SinhVienRepository studentRepo;
    private final GiangVienRepository lecturerRepo;

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
                user.getVaiTro(), user.getTrangThaiKichHoat());
    }

    public AuthResponse login(LoginRequest req) {
        Authentication auth = authManager.authenticate(
                new UsernamePasswordAuthenticationToken(req.getEmail(), req.getMatKhau()));

        var principal = (org.springframework.security.core.userdetails.User) auth.getPrincipal();
        var domainUser = usersRepo.findByEmail(principal.getUsername()).orElseThrow();

        List<String> roles = principal.getAuthorities().stream()
                .map(a -> a.getAuthority()).toList();

        Long studentId = null, teacherId = null;
        String fullName = null, duongDanAvt = null;

        var svOpt = studentRepo.findByUserId(domainUser.getId());
        if (svOpt.isPresent()) {
            var sv = svOpt.get();
            studentId = sv.getId();
            fullName  = sv.getHoTen();
            duongDanAvt = sv.getDuongDanAvt();
        }

        var gvOpt = lecturerRepo.findByUserId(domainUser.getId());
        if (gvOpt.isPresent()) {
            var gv = gvOpt.get();
            teacherId = gv.getId();
            if (gv.getHoTen() != null && !gv.getHoTen().isBlank()) {
                fullName = gv.getHoTen(); // ưu tiên tên GV nếu có

            }
            duongDanAvt = gv.getDuongDanAvt();
        }

        String token = jwt.generate(domainUser.getEmail(), Map.of("roles", roles));
        long expiresAt = jwt.getExpiryEpochMillis(token);

        var userResp = UserResponse.of(
                domainUser.getId(),
                fullName,
                domainUser.getEmail(),
                domainUser.getVaiTro(),
                duongDanAvt,
                domainUser.getTrangThaiKichHoat(),
                teacherId,
                studentId
        );

        return AuthResponse.of(token, expiresAt, userResp);
    }

    public UserResponse me(String email) {
        var user = usersRepo.findByEmail(email).orElseThrow();

        Long studentId = null, teacherId = null;
        String fullName = null, duongDanAvt = null;

        var svOpt = studentRepo.findByUserId(user.getId());
        if (svOpt.isPresent()) {
            var sv = svOpt.get();
            studentId = sv.getId();
            fullName  = sv.getHoTen();
            duongDanAvt = sv.getDuongDanAvt();
        }

        var gvOpt = lecturerRepo.findByUserId(user.getId());
        if (gvOpt.isPresent()) {
            var gv = gvOpt.get();
            teacherId = gv.getId();
            if (gv.getHoTen() != null && !gv.getHoTen().isBlank()) {
                fullName = gv.getHoTen();
            }
            duongDanAvt = gv.getDuongDanAvt();
        }

        return UserResponse.of(
                user.getId(),
                fullName,
                user.getEmail(),
                user.getVaiTro(),
                duongDanAvt,
                user.getTrangThaiKichHoat(),
                teacherId,
                studentId
        );
    }
    public void logout() { /* no-op */ }
}
