package com.backend.gpms.features.auth.application;

import com.backend.gpms.common.security.JwtUtils;
import com.backend.gpms.features.auth.domain.PasswordResetToken;
import com.backend.gpms.features.auth.domain.User;
import com.backend.gpms.features.auth.dto.request.ChangePasswordRequest;
import com.backend.gpms.features.auth.dto.request.ForgotPasswordRequest;
import com.backend.gpms.features.auth.dto.request.LoginRequest;
import com.backend.gpms.features.auth.dto.request.ResetPasswordRequest;
import com.backend.gpms.features.auth.dto.response.AuthResponse;
import com.backend.gpms.features.auth.dto.response.UserResponse;
import com.backend.gpms.features.auth.infra.PasswordResetTokenRepository;
import com.backend.gpms.features.auth.infra.UserRepository;
import com.backend.gpms.features.lecturer.infra.GiangVienRepository;
import com.backend.gpms.features.student.infra.SinhVienRepository;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.*;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.time.Duration;
import java.time.Instant;
import java.util.Base64;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
@FieldDefaults( level = AccessLevel.PRIVATE)
@Transactional
public class AuthService {
    private final UserRepository usersRepo;
    private final PasswordEncoder encoder;
    private final AuthenticationManager authManager;
    private final JwtUtils jwt;
    private final SinhVienRepository studentRepo;
    private final GiangVienRepository lecturerRepo;
    PasswordResetTokenRepository prtRepo;
    PasswordResetMailer mailer;

      @org.springframework.beans.factory.annotation.Value("${app.auth.password-reset-exp-minutes:30}")
      private int resetExpMinutes;

      @org.springframework.beans.factory.annotation.Value("${app.auth.password-reset-cooldown-seconds:60}")
      private int resetCooldownSeconds;

      @org.springframework.beans.factory.annotation.Value("${app.reset-password.base-url}")
      private String resetBaseUrl;

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


    public void logout(){};


    public void changePassword(String email, ChangePasswordRequest req) {
        var user = usersRepo.findByEmail(email).orElseThrow();
        if (!encoder.matches(req.getCurrentPassword(), user.getMatKhau())) {
            throw new BadCredentialsException("Mật khẩu hiện tại không đúng");
        }
        user.setMatKhau(encoder.encode(req.getNewPassword()));
        // cập nhật 'updated_at' tự động bằng trigger/hook hoặc @PreUpdate nếu bạn có
        usersRepo.save(user);

        // thu hồi mọi token reset còn lại
        prtRepo.deleteByUser(user);
    }

    public void forgotPassword(ForgotPasswordRequest req) {
        // Không tiết lộ sự tồn tại của email
        Optional<User> userOpt = usersRepo.findByEmail(req.getEmail());
        if (userOpt.isEmpty()) {
            log.info("ForgotPassword requested for non-existing email={}", req.getEmail());
            return;
        }
        var user = userOpt.get();

        // cooldown (tùy chọn)
        prtRepo.findTopByUserAndUsedFalseOrderByCreatedAtDesc(user).ifPresent(last -> {
            var elapsed = Duration.between(last.getCreatedAt(), Instant.now()).getSeconds();
            if (elapsed < resetCooldownSeconds) {
                throw new BadCredentialsException("Vui lòng thử lại sau ít phút.");
            }
        });

        // Thu hồi token cũ trước khi cấp token mới
        prtRepo.deleteByUser(user);

        String rawToken = generateRandomToken();
        String tokenHash = sha256(rawToken);
        Instant expiresAt = Instant.now().plus(Duration.ofMinutes(resetExpMinutes));

        prtRepo.save(
                PasswordResetToken.builder()
                        .user(user)
                        .tokenHash(tokenHash)
                        .expiresAt(expiresAt)
                        .used(false)
                        .build()
        );

        String resetLink = resetBaseUrl + "?token=" + rawToken;
        mailer.sendResetLink(user.getEmail(), resetLink);
    }

    public void resetPassword(ResetPasswordRequest req) {
        String hash = sha256(req.getToken());
        var prt = prtRepo.findByTokenHashAndUsedFalseAndExpiresAtAfter(hash, Instant.now())
                .orElseThrow(() -> new BadCredentialsException("Token không hợp lệ hoặc đã hết hạn"));

        var user = prt.getUser();
        user.setMatKhau(encoder.encode(req.getNewPassword()));
        usersRepo.save(user);

        // Đánh dấu token đã dùng và thu hồi các token khác
        prt.setUsed(true);
        prtRepo.save(prt);
        prtRepo.deleteByUser(user);
    }

    /* ===================== helpers ===================== */
    private static String generateRandomToken() {
        byte[] buf = new byte[32];
        new SecureRandom().nextBytes(buf);
        // Base64URL không có padding để đưa vào query an toàn
        return Base64.getUrlEncoder().withoutPadding().encodeToString(buf);
    }

    private static String sha256(String raw) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] bytes = md.digest(raw.getBytes(StandardCharsets.UTF_8));
            return Base64.getEncoder().encodeToString(bytes);
        } catch (Exception e) {
            throw new IllegalStateException("Hash error", e);
        }
    }

}
