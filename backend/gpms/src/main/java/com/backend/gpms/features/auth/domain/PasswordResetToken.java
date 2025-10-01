// src/main/java/com/backend/gpms/features/auth/domain/PasswordResetToken.java
package com.backend.gpms.features.auth.domain;

import jakarta.persistence.*;
import lombok.*;
import java.time.Instant;

@Getter @Setter
@NoArgsConstructor @AllArgsConstructor @Builder
@Entity @Table(name = "password_reset_token",
        indexes = {
                @Index(name="idx_prt_user_expires", columnList = "user_id,expires_at")
        },
        uniqueConstraints = @UniqueConstraint(name="uq_prt_hash", columnNames = "token_hash")
)
public class PasswordResetToken {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    @JoinColumn(name="user_id", nullable = false)
    private User user; // com.backend.gpms.features.auth.domain.User (tương ứng bảng tai_khoan)

    @Column(name="token_hash", nullable = false)
    private String tokenHash; // SHA-256 của token thô

    @Column(name="expires_at", nullable = false)
    private Instant expiresAt;

    @Column(name="used", nullable = false)
    private boolean used = false;

    @Column(name="created_at", nullable = false)
    private Instant createdAt = Instant.now();
}
