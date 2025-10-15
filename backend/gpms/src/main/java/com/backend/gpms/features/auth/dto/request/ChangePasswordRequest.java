package com.backend.gpms.features.auth.dto.request;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.experimental.FieldDefaults;

@Getter
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
public class ChangePasswordRequest {
    @NotBlank  @Size(min = 3, max = 128, message = "PASSWORD_INVALID")
    String currentPassword;
    @NotBlank @Size(min = 6, max = 128, message = "PASSWORD_INVALID")
    String newPassword;
}
