// src/main/java/com/backend/gpms/features/auth/infra/PasswordResetTokenRepository.java
package com.backend.gpms.features.auth.infra;

import com.backend.gpms.features.auth.domain.PasswordResetToken;
import com.backend.gpms.features.auth.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.Instant;
import java.util.Optional;

public interface PasswordResetTokenRepository extends JpaRepository<PasswordResetToken, Long> {
    Optional<PasswordResetToken> findByTokenHashAndUsedFalseAndExpiresAtAfter(String tokenHash, Instant now);
    void deleteByUser(User user);

    // optional: kiểm soát tần suất gửi mail
    Optional<PasswordResetToken> findTopByUserAndUsedFalseOrderByCreatedAtDesc(User user);
}
