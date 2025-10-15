package com.backend.gpms.features.auth.infra;

import com.backend.gpms.features.auth.domain.TokenBlacklist;
import com.backend.gpms.features.auth.domain.TokenPurpose;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface TokenBlacklistRepository extends JpaRepository<TokenBlacklist, Long> {
    boolean existsByTokenHashAndPurposeIn(String tokenHash, List<TokenPurpose> purposes);
    Optional<TokenBlacklist> findByTokenHashAndPurpose(String tokenHash, TokenPurpose purpose);
    void deleteByExpiresAtBefore(java.time.Instant instant);
}
