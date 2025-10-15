package com.backend.gpms.features.auth.application;

import com.backend.gpms.common.exception.ApplicationException;
import com.backend.gpms.common.exception.ErrorCode;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.time.format.DateTimeFormatter;

@Slf4j
@Component
@RequiredArgsConstructor
@ConditionalOnProperty(prefix = "spring.mail", name = "host")
public class EmailService {

    private final JavaMailSender mailSender;

    @Value("${spring.mail.from:no-reply@gpms.local}")
    private String from;

    @Value("${frontend.url:http://localhost:3000}")
    private String frontendUrl;

    public void sendResetPasswordEmail(String to, String resetToken, String userFullName) {
        try {
            String resetLink = String.format("%s/reset-password?token=%s", frontendUrl, resetToken);
            MimeMessage msg = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(msg, true, "UTF-8");
            helper.setFrom(from);
            helper.setTo(to);
            helper.setSubject("[GPMS] Đặt lại mật khẩu");
            helper.setText("""
                <p>Chào %s,</p>
                <p>Chúng tôi nhận được yêu cầu đặt lại mật khẩu cho tài khoản GPMS của bạn vào %s.</p>
                <p>Nhấp vào liên kết dưới đây để đặt lại mật khẩu (liên kết có hiệu lực trong 1 giờ):</p>
                <p><a href="%s">%s</a></p>
                <p>Nếu bạn không thực hiện yêu cầu này, vui lòng bỏ qua email hoặc liên hệ hỗ trợ.</p>
                <p>Trân trọng,<br>Đội ngũ GPMS</p>
                """.formatted(
                    userFullName != null ? userFullName : "người dùng",
                    DateTimeFormatter.ISO_LOCAL_DATE_TIME.format(Instant.now()),
                    resetLink,
                    resetLink
            ), true);
            mailSender.send(msg);
            log.info("Sent password reset email to: {}", to);
        } catch (MessagingException e) {
            log.error("Failed to send password reset email to: {}", to, e);
            throw new ApplicationException(ErrorCode.INTERNAL_SERVER_ERROR);
        }
    }
}
