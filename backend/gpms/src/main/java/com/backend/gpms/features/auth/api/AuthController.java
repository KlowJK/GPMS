package com.backend.gpms.features.auth.api;

import com.backend.gpms.common.util.ApiResponse;
import com.backend.gpms.features.auth.application.AuthService;
import com.backend.gpms.features.auth.dto.request.ChangePasswordRequest;
import com.backend.gpms.features.auth.dto.request.ForgotPasswordRequest;
import com.backend.gpms.features.auth.dto.request.LoginRequest;
import com.backend.gpms.features.auth.dto.request.ResetPasswordRequest;
import com.backend.gpms.features.auth.dto.response.AuthResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
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
    public ApiResponse<AuthResponse> login(
            @RequestBody @Valid LoginRequest req) {
        return ApiResponse.success(service.login(req));
    }


    @PostMapping("/logout")
    public ApiResponse<Void> logout() {
        service.logout();
        return ApiResponse.success(null);
    }

    @PostMapping("/forgot-password")
    public ApiResponse<Void> forgotPassword(@RequestBody @Valid ForgotPasswordRequest req) {
        service.forgotPassword(req);
        return ApiResponse.success(null); // luôn 200, không tiết lộ email có tồn tại
    }

    @PostMapping("/reset-password")
    public ApiResponse<Void> resetPassword(@RequestBody @Valid ResetPasswordRequest req) {
        service.resetPassword(req);
        return ApiResponse.success(null);
    }

    @PostMapping("/change-password")
    public ApiResponse<Void> changePassword(@AuthenticationPrincipal User principal,
                                               @RequestBody @Valid ChangePasswordRequest req) {
        service.changePassword(principal.getUsername(), req);
        return ApiResponse.success(null);
    }
}
