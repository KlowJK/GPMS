package com.backend.gpms.features.auth.infra;

import com.backend.gpms.features.auth.domain.TokenBlacklist;
import com.backend.gpms.features.auth.domain.TokenPurpose;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.Optional;

public interface TokenBlacklistRepository extends JpaRepository<TokenBlacklist, Long> {
    boolean existsByTokenHashAndPurposeIn(String tokenHash, List<TokenPurpose> purposes);
    Optional<TokenBlacklist> findByTokenHashAndPurpose(String tokenHash, TokenPurpose purpose);

    @Modifying
    @Transactional
    @Query("delete from TokenBlacklist t where t.expiresAt < :instant")
    void deleteByExpiresAtBefore(Instant instant);

}
