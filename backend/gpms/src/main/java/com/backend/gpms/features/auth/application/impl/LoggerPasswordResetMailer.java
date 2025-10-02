package com.backend.gpms.features.auth.application.impl;


import com.backend.gpms.features.auth.application.PasswordResetMailer;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@ConditionalOnMissingBean(PasswordResetMailer.class)
public class LoggerPasswordResetMailer implements PasswordResetMailer {
    @Override
    public void sendResetLink(String to, String resetLink) {
        log.info("[DEV] Reset password link for {} -> {}", to, resetLink);
    }
}