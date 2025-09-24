package com.backend.gpms.features.auth.dto;

import lombok.*;

@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AuthResponse {
    private String accessToken;    // JWT
    @Builder.Default
    private String tokenType = "Bearer";
    private Long   expiresAt;      // epoch millis
    private UserResponse user;     // thông tin người dùng

    /** Tiện lợi: chỉ token */
    public AuthResponse(String accessToken) {
        this.accessToken = accessToken;
        this.tokenType = "Bearer";
    }

    /** Tiện lợi: token + hết hạn + user */
    public static AuthResponse of(String token, long expiresAt, UserResponse user) {
        return AuthResponse.builder()
                .accessToken(token)
                .tokenType("Bearer")
                .expiresAt(expiresAt)
                .user(user)
                .build();
    }
}
