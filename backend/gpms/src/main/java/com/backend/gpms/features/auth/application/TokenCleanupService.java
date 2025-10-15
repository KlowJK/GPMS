package com.backend.gpms.features.auth.application;

import com.backend.gpms.features.auth.infra.TokenBlacklistRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.Instant;

@Service
@RequiredArgsConstructor
@Slf4j
public class TokenCleanupService {
    private final TokenBlacklistRepository tokenBlacklistRepo;

    @Scheduled(cron = "0 0 0 * * ?") // Chạy hàng ngày lúc 0:00
    public void cleanExpiredTokens() {
        tokenBlacklistRepo.deleteByExpiresAtBefore(Instant.now());
        log.info("Cleaned expired tokens from token_blacklist");
    }
}