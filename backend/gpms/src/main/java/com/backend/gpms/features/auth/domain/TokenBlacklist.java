package com.backend.gpms.features.auth.domain;

import com.backend.gpms.common.util.BaseEntity;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.Instant;


@Entity
@Table(name = "token_blacklist")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
public class TokenBlacklist extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id;

    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    User user;

    @Column(name = "token_hash", nullable = false, unique = true)
    String tokenHash; // SHA-256 của token


    @Enumerated(EnumType.STRING)
    @Column(name = "purpose", nullable = false, columnDefinition = "token_purpose")
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)   // <— quan trọng cho PostgreSQL enum
    TokenPurpose purpose; // LOGOUT, CHANGE_PASSWORD, RESET_PASSWORD

    @Column(name = "expires_at", nullable = false)
    Instant expiresAt;

    @Column(name = "used", nullable = false)
   boolean used = false; // Chỉ áp dụng cho RESET_PASSWORD
}