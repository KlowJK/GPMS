package com.backend.gpms.features.auth.application;

import com.backend.gpms.common.security.JwtUtils;
import com.backend.gpms.features.auth.domain.User;
import com.backend.gpms.features.auth.dto.*;
import com.backend.gpms.features.auth.infra.UserRepository;
import org.springframework.security.authentication.*;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;
import java.util.stream.Collectors;

@Service
public class AuthService {
    private final UserRepository usersRepo;
    private final PasswordEncoder encoder;
    private final AuthenticationManager authManager;
    private final JwtUtils jwt;

    public AuthService(UserRepository usersRepo, PasswordEncoder encoder,
                       AuthenticationManager authManager, JwtUtils jwt) {
        this.usersRepo = usersRepo; this.encoder = encoder; this.authManager = authManager; this.jwt = jwt;
    }

    @Transactional
    public UserResponse register(RegisterRequest req) {
        if (usersRepo.existsByEmail(req.getEmail()))
            throw new IllegalArgumentException("Email đã tồn tại");

        User user = new User();
        user.setEmail(req.getEmail());
        user.setMatKhau(encoder.encode(req.getMatKhau()));
        user.setSoDienThoai(req.getSoDienThoai());
        user.setVaiTro(req.getVaiTro());
        user = usersRepo.save(user);

        return new UserResponse(user.getId(), user.getEmail(),user.getSoDienThoai(),
                user.getVaiTro(),user.getTrangThaiKichHoat());
    }

    public AuthResponse login(LoginRequest req) {
        Authentication auth = authManager.authenticate(
                new UsernamePasswordAuthenticationToken(req.getEmail(), req.getMatKhau()));
        var principal = (org.springframework.security.core.userdetails.User) auth.getPrincipal();

        String token = jwt.generate(principal.getUsername(), Map.of("roles", principal.getAuthorities()
                .stream().map(a -> a.getAuthority()).collect(Collectors.toList())));
        return new AuthResponse(token);
    }

    public UserResponse me(String email) {
        var user = usersRepo.findByEmail(email).orElseThrow();
        return new UserResponse(user.getId(), user.getEmail(), user.getSoDienThoai(), user.getVaiTro(), user.getTrangThaiKichHoat());
    }
}
