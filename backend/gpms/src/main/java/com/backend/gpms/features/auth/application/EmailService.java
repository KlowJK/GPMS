package com.backend.gpms.features.auth.application;

import com.backend.gpms.common.exception.ApplicationException;
import com.backend.gpms.common.exception.ErrorCode;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;

@Slf4j
@Component
@RequiredArgsConstructor
@ConditionalOnProperty(prefix = "spring.mail", name = "host")
public class EmailService {

    private final JavaMailSender mailSender;

    @Value("${spring.mail.from:no-reply@gpms.local}")
    private String from;

    public void sendResetPasswordEmail(String to, String resetToken, String userFullName) {
        try {
            MimeMessage msg = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(msg, true, "UTF-8");

            // 1. ẨN EMAIL NGƯỜI GỬI → Dùng tên + email
            helper.setFrom(new InternetAddress(from, "GPMS", "UTF-8"));

            helper.setTo(to);
            helper.setSubject("[GPMS] Đặt lại mật khẩu");

            // 2. CHỈ GỬI TOKEN (không link)
            helper.setText("""
                    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: auto; padding: 20px; border: 1px solid #ddd; border-radius: 10px;">
                                <h2 style="color: #000000; text-align: center;">GPMS - Đặt lại mật khẩu</h2>
                                <p>Chào %s,</p>
                                <p>Chúng tôi nhận được yêu cầu đặt lại mật khẩu cho tài khoản GPMS của bạn vào <strong>%s</strong>.</p>
                                <p>Vui lòng sử dụng mã token sau để đặt lại mật khẩu (hiệu lực trong <strong>1 giờ</strong>):</p>
                                <p><strong>%s</strong></p>
                                <p>Nếu bạn không thực hiện yêu cầu này, vui lòng bỏ qua email hoặc liên hệ hỗ trợ.</p>
                                <p>Trân trọng,<br>Đội ngũ GPMS</p>
                    </div>
                    """.formatted(
                    userFullName != null ? userFullName : "người dùng",
                    ZonedDateTime.now(ZoneId.systemDefault())
                            .format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")),
                    resetToken  // ← Chỉ gửi token
            ), true);

            mailSender.send(msg);
            log.info("Sent password reset email with token to: {}", to);
        } catch (Exception e) {
            log.error("Failed to send password reset email to: {}", to, e);
            throw new ApplicationException(ErrorCode.INTERNAL_SERVER_ERROR);
        }
    }

    public void sendHtmlEmail(String to, String subject, String htmlBody) {
        try {
            MimeMessage msg = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(msg, true, "UTF-8");
            helper.setFrom(from);
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(htmlBody, true);
            mailSender.send(msg);
            log.info("Sent notification email to: {}", to);
        } catch (MessagingException e) {
            log.error("Failed to send email to: {}", to, e);
        }
    }
}
