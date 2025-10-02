package com.backend.gpms.features.auth.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter; @Getter
public class ResetPasswordRequest {
    @NotBlank private String token; // token thô từ email
    @NotBlank @Size(min = 8, max = 128) private String newPassword;
}