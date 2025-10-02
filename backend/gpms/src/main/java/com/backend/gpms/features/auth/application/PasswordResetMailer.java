package com.backend.gpms.features.auth.application;

public interface PasswordResetMailer {
    void sendResetLink(String to, String resetLink);
}