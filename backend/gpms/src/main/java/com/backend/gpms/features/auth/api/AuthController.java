package com.backend.gpms.features.auth.api;

import com.backend.gpms.common.exception.ApplicationException;
import com.backend.gpms.common.exception.ErrorCode;
import com.backend.gpms.common.util.ApiResponse;
import com.backend.gpms.features.auth.application.AuthService;
import com.backend.gpms.features.auth.dto.request.ChangePasswordRequest;

import com.backend.gpms.features.auth.dto.request.LoginRequest;
import com.backend.gpms.features.auth.dto.request.ResetPasswordRequest;
import com.backend.gpms.features.auth.dto.response.AuthResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

@Tag(name = "Auth")
@RestController
@RequestMapping("/api/auth")
@AllArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/login")
    public ApiResponse<AuthResponse> login(
            @RequestBody @Valid LoginRequest req) {
        return ApiResponse.success(authService.login(req));
    }

    @PostMapping("/logout")
    public ApiResponse<String> logout(@RequestHeader(value = "Authorization", required = false) String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            throw new ApplicationException(ErrorCode.INVALID_TOKEN);
        }
        String token = authHeader.substring(7);
        authService.logout(token);
        return ApiResponse.success("Logged out successfully.");
    }

    @PostMapping("/change-password")
    public ApiResponse<String> changePassword( @RequestHeader("Authorization") String authHeader,
                                                            @Valid @RequestBody ChangePasswordRequest req) {
        authService.changePassword(authHeader.substring(7), req);
        return ApiResponse.success("Password changed successfully.");
    }

    @PostMapping("/request-reset-password")
    public ApiResponse<String> requestPasswordReset(@RequestBody Map<String, String> request) {
        authService.requestPasswordReset(request.get("email"));
        return ApiResponse.success("If the email is registered, a reset link has been sent.");
    }

    @PostMapping("/reset-password")
    public ApiResponse<String> resetPassword(@Valid @RequestBody ResetPasswordRequest req) {
        authService.resetPassword(req);
        return ApiResponse.success("Password has been reset successfully.");
    }

    @PostMapping(value = "/update-avt", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ApiResponse<String> updateAvatar(MultipartFile file) throws Exception {
        String imageUrl = authService.uploadAnhDaiDien( file);
        return ApiResponse.success("Avatar updated successfully: " + imageUrl);
    }


}