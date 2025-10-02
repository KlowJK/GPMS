package com.backend.gpms.features.auth.application.impl;

import com.backend.gpms.features.auth.application.PasswordResetMailer;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Component;


@Slf4j
@Component
@RequiredArgsConstructor
@ConditionalOnProperty(prefix = "spring.mail", name = "host")
public class JavaMailPasswordResetMailer implements PasswordResetMailer {

    private final JavaMailSender mailSender;

    @Value("${spring.mail.from:no-reply@gpms.local}")
    String from;

    @Override
    public void sendResetLink(String to, String resetLink) {
        try {
            MimeMessage msg = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(msg, "UTF-8");
            helper.setFrom(from);
            helper.setTo(to);
            helper.setSubject("[GPMS] Đặt lại mật khẩu");
            helper.setText("""
                <p>Chào bạn,</p>
                <p>Chúng tôi nhận được yêu cầu đặt lại mật khẩu cho tài khoản GPMS của bạn.</p>
                <p>Nhấp vào liên kết để đặt lại (hiệu lực 30 phút):</p>
                <p><a href="%s">%s</a></p>
                <p>Nếu không phải bạn yêu cầu, vui lòng bỏ qua email này.</p>
                """.formatted(resetLink, resetLink), true);
            mailSender.send(msg);
        } catch (MessagingException e) {
            log.error("Send reset mail failed", e);
        }
    }
}
