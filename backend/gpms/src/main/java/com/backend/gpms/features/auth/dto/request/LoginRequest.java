package com.backend.gpms.features.auth.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldDefaults;

@Setter
@Getter
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
public class LoginRequest {
    @Email(message = "EMAIL_INVALID", regexp = "^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$")
    @NotBlank
    String email;
    @Size(min = 3, message = "PASSWORD_INVALID")
    @NotBlank
    String matKhau;

}
