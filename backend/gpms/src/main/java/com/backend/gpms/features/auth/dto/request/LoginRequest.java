package com.backend.gpms.features.auth.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
public class LoginRequest {
    @Email( regexp = "^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$")
    @NotBlank
    private String email;
    @NotBlank private String matKhau;

}
