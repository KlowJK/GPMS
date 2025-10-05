package com.backend.gpms.features.auth.api;

import com.backend.gpms.features.auth.application.AuthService;
import com.backend.gpms.features.auth.dto.request.ChangePasswordRequest;
import com.backend.gpms.features.auth.dto.request.ForgotPasswordRequest;
import com.backend.gpms.features.auth.dto.request.LoginRequest;
import com.backend.gpms.features.auth.dto.request.ResetPasswordRequest;
import com.backend.gpms.features.auth.dto.response.AuthResponse;
import com.backend.gpms.features.auth.dto.response.UserResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.User;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Auth")
@RestController
@RequestMapping("/api/auth")
@AllArgsConstructor
public class AuthController {

    private final AuthService service;

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@RequestBody @Valid LoginRequest req) {
        return ResponseEntity.ok(service.login(req));
    }


    @PostMapping("/logout")
    public ResponseEntity<Void> logout() {
        service.logout();
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<Void> forgotPassword(@RequestBody @Valid ForgotPasswordRequest req) {
        service.forgotPassword(req);
        return ResponseEntity.ok().build(); // luôn 200, không tiết lộ email có tồn tại
    }

    @PostMapping("/reset-password")
    public ResponseEntity<Void> resetPassword(@RequestBody @Valid ResetPasswordRequest req) {
        service.resetPassword(req);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/change-password")
    public ResponseEntity<Void> changePassword(@AuthenticationPrincipal User principal,
                                               @RequestBody @Valid ChangePasswordRequest req) {
        service.changePassword(principal.getUsername(), req);
        return ResponseEntity.noContent().build();
    }
}
