package com.backend.gpms.features.auth.application;

import com.backend.gpms.common.exception.ApplicationException;
import com.backend.gpms.common.exception.ErrorCode;
import com.backend.gpms.common.security.JwtUtils;
import com.backend.gpms.common.util.HashUtils;
import com.backend.gpms.features.auth.domain.TokenBlacklist;
import com.backend.gpms.features.auth.domain.TokenPurpose;
import com.backend.gpms.features.auth.domain.User;
import com.backend.gpms.features.auth.dto.request.ChangePasswordRequest;
import com.backend.gpms.features.auth.dto.request.LoginRequest;
import com.backend.gpms.features.auth.dto.request.ResetPasswordRequest;
import com.backend.gpms.features.auth.dto.response.AuthResponse;
import com.backend.gpms.features.auth.dto.response.UserResponse;
import com.backend.gpms.features.auth.infra.TokenBlacklistRepository;
import com.backend.gpms.features.auth.infra.UserRepository;
import com.backend.gpms.features.lecturer.infra.GiangVienRepository;
import com.backend.gpms.features.storage.application.CloudinaryStorageService;
import com.backend.gpms.features.student.infra.SinhVienRepository;
import io.jsonwebtoken.JwtException;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.*;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
@Transactional
public class AuthService {
    UserRepository usersRepository;
    AuthenticationManager authManager;
    JwtUtils jwt;
    SinhVienRepository studentRepo;
    GiangVienRepository lecturerRepo;
    TokenBlacklistRepository tokenBlacklistRepository;
    CloudinaryStorageService cloudinaryStorageService;
    PasswordEncoder passwordEncoder;
    EmailService emailService;

    public AuthResponse login(LoginRequest req) {
        // Kiểm tra email tồn tại trước
        if (!usersRepository.existsByEmail(req.getEmail())) {
            log.warn("Login failed: Email not found - {}", req.getEmail());
            throw new ApplicationException(ErrorCode.USER_NOT_FOUND);
        }

        try {
            Authentication auth = authManager.authenticate(
                    new UsernamePasswordAuthenticationToken(req.getEmail(), req.getMatKhau()));

            var principal = (org.springframework.security.core.userdetails.User) auth.getPrincipal();
            var domainUser = usersRepository.findByEmail(principal.getUsername()).orElseThrow(() ->
                    new ApplicationException(ErrorCode.USER_NOT_FOUND));

            List<String> roles = principal.getAuthorities().stream()
                    .map(GrantedAuthority::getAuthority)
                    .toList();

            Long studentId = null, teacherId = null;
            String fullName = null;

            var svOpt = studentRepo.findByUserId(domainUser.getId());
            if (svOpt.isPresent()) {
                var sv = svOpt.get();
                studentId = sv.getId();
                fullName = sv.getHoTen();

            }

            var gvOpt = lecturerRepo.findByUserId(domainUser.getId());
            if (gvOpt.isPresent()) {
                var gv = gvOpt.get();
                teacherId = gv.getId();
                if (gv.getHoTen() != null && !gv.getHoTen().isBlank()) {
                    fullName = gv.getHoTen(); // Ưu tiên tên GV nếu có
                }

            }

            String token = jwt.generate(domainUser.getEmail(), Map.of("roles", roles));
            long expiresAt = jwt.getExpiryEpochMillis(token);

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

            return AuthResponse.of(token, expiresAt, userResp);
        } catch (BadCredentialsException e) {
            log.warn("Login failed: Wrong password for email - {}", req.getEmail());
            throw new ApplicationException(ErrorCode.WRONG_PASSWORD);
        } catch (DisabledException e) {
            log.warn("Login failed: Account disabled for email - {}", req.getEmail());
            throw new ApplicationException(ErrorCode.INACTIVATED_ACCOUNT);
        } catch (AuthenticationException e) {
            log.error("Login failed: Authentication error for email - {}", req.getEmail(), e);
            throw new ApplicationException(ErrorCode.UNAUTHENTICATED);
        } catch (Exception e) {
            log.error("Unexpected error during login for email: {}", req.getEmail(), e);
            throw new ApplicationException(ErrorCode.INTERNAL_SERVER_ERROR);
        }
    }


    public void logout(String token) {
        try {
            if (!jwt.isExpired(token)) {
                String email = jwt.getSubject(token);
                User user = usersRepository.findByEmail(email)
                        .orElseThrow(() -> new ApplicationException(ErrorCode.USER_NOT_FOUND));
                String tokenHash = HashUtils.sha256(token);
                TokenBlacklist blacklist = new TokenBlacklist();
                blacklist.setUser(user);
                blacklist.setTokenHash(tokenHash);
                blacklist.setPurpose(TokenPurpose.LOGOUT);
                blacklist.setExpiresAt(Instant.ofEpochMilli(jwt.getExpiryEpochMillis(token)));
                blacklist.setUsed(false);
                tokenBlacklistRepository.save(blacklist);
                log.info("Token blacklisted for logout: userId={}, purpose=LOGOUT", user.getId());
            } else {
                throw new ApplicationException(ErrorCode.TOKEN_EXPIRED);
            }
        } catch (JwtException e) {
            throw new ApplicationException(ErrorCode.INVALID_TOKEN);
        }
    }

    public void changePassword(String token, ChangePasswordRequest req) {
        try {
            if (!jwt.isExpired(token)) {
                String email = jwt.getSubject(token);
                User user = usersRepository.findByEmail(email)
                        .orElseThrow(() -> new ApplicationException(ErrorCode.USER_NOT_FOUND));
                if (!passwordEncoder.matches(req.getCurrentPassword(), user.getMatKhau())) {
                    throw new ApplicationException(ErrorCode.WRONG_PASSWORD);
                }
                user.setMatKhau(passwordEncoder.encode(req.getNewPassword()));
                usersRepository.save(user);

                // Blacklist token hiện tại
                String tokenHash = HashUtils.sha256(token);
                TokenBlacklist blacklist = new TokenBlacklist();
                blacklist.setUser(user);
                blacklist.setTokenHash(tokenHash);
                blacklist.setPurpose(TokenPurpose.CHANGE_PASSWORD);
                blacklist.setExpiresAt(Instant.ofEpochMilli(jwt.getExpiryEpochMillis(token)));
                blacklist.setUsed(false); // Không cần used
                tokenBlacklistRepository.save(blacklist);
                log.info("Token blacklisted for change password: userId={}, purpose=CHANGE_PASSWORD", user.getId());
            } else {
                throw new ApplicationException(ErrorCode.TOKEN_EXPIRED);
            }
        } catch (JwtException e) {
            throw new ApplicationException(ErrorCode.INVALID_TOKEN);
        }
    }

    public void requestPasswordReset(String email) {
        User user = usersRepository.findByEmail(email)
                .orElseThrow(() -> new ApplicationException(ErrorCode.USER_NOT_FOUND));
        String resetToken = UUID.randomUUID().toString();
        String tokenHash = HashUtils.sha256(resetToken);
        TokenBlacklist blacklist = new TokenBlacklist();
        blacklist.setUser(user);
        blacklist.setTokenHash(tokenHash);
        blacklist.setPurpose(TokenPurpose.RESET_PASSWORD);
        blacklist.setExpiresAt(Instant.now().plus(1, ChronoUnit.HOURS));
        blacklist.setUsed(false);
        tokenBlacklistRepository.save(blacklist);

        // Lấy fullName từ Student hoặc Lecturer
        String fullName = null;
        var svOpt = studentRepo.findByUserId(user.getId());
        if (svOpt.isPresent()) {
            fullName = svOpt.get().getHoTen();
        }
        var gvOpt = lecturerRepo.findByUserId(user.getId());
        if (gvOpt.isPresent() && gvOpt.get().getHoTen() != null && !gvOpt.get().getHoTen().isBlank()) {
            fullName = gvOpt.get().getHoTen();
        }

        emailService.sendResetPasswordEmail(user.getEmail(), resetToken, fullName);
        log.info("Password reset token created: userId={}, purpose=RESET_PASSWORD", user.getId());
    }

    public void resetPassword(ResetPasswordRequest request) {
        String tokenHash = HashUtils.sha256(request.getToken());
        TokenBlacklist token = tokenBlacklistRepository.findByTokenHashAndPurpose(tokenHash, TokenPurpose.RESET_PASSWORD)
                .orElseThrow(() -> new ApplicationException(ErrorCode.INVALID_TOKEN));
        if (token.isUsed()) {
            throw new ApplicationException(ErrorCode.INVALID_TOKEN);
        }
        if (token.getExpiresAt().isBefore(Instant.now())) {
            throw new ApplicationException(ErrorCode.TOKEN_EXPIRED);
        }
        User user = token.getUser();
        user.setMatKhau(passwordEncoder.encode(request.getNewPassword()));
        token.setUsed(true); // Đánh dấu token đã dùng
        usersRepository.save(user);
        tokenBlacklistRepository.save(token);
        log.info("Password reset successful: userId={}", user.getId());
    }



    public String uploadAnhDaiDien(MultipartFile file) throws IOException {
        var auth =  SecurityContextHolder.getContext().getAuthentication();
        log.info("Authenticated user: {}", auth.getName());
        User taiKhoan = usersRepository.findByEmail(auth.getName())
                .orElseThrow(() -> new ApplicationException(ErrorCode.USER_NOT_FOUND));
        String anhDaiDienUrl = cloudinaryStorageService.upload(file);
        taiKhoan.setDuongDanAvt(anhDaiDienUrl);
        usersRepository.save(taiKhoan);
        return "Upload anh dai dien thanh cong";
    }

}
