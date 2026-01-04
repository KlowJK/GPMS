package com.backend.gpms.common.security;

import com.backend.gpms.common.exception.ApplicationException;
import com.backend.gpms.common.exception.ErrorCode;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import lombok.Getter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.Map;

@Getter
@Component
public class JwtUtils {

    private final SecretKey key;     // HMAC key >= 32 bytes
    private final long expirationMs;

    public JwtUtils(
            @Value("${app.jwt.secret}") String secret,
            @Value("${app.jwt.expiration-ms:86400000}") long expirationMs) {

        // đảm bảo đủ độ dài cho HS256 (>= 32 bytes)
        byte[] bytes = secret.getBytes(StandardCharsets.UTF_8);
        if (bytes.length < 32) {
            throw new IllegalArgumentException("app.jwt.secret phải >= 32 bytes");
        }
        this.key = Keys.hmacShaKeyFor(bytes);
        this.expirationMs = expirationMs;
    }

    public String generate(String subject, Map<String, Object> claims) {
        long now = System.currentTimeMillis();
        return Jwts.builder()
                .claims(claims)
                .subject(subject)                           // email
                .issuedAt(new Date(now))
                .expiration(new Date(now + expirationMs))   // exp
                .signWith(key, Jwts.SIG.HS256)              // chỉ rõ thuật toán
                .compact();
    }

    // Trong JwtUtils
    public Claims parse(String token) {
        try {
            return Jwts.parser()
                    .verifyWith(key)
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();
        } catch (ExpiredJwtException e) {
            throw new ApplicationException(ErrorCode.TOKEN_EXPIRED);
        } catch (JwtException e) {
            throw new ApplicationException(ErrorCode.INVALID_TOKEN);
        }
    }

    public boolean isExpired(String token) {
        try {
            Date exp = parse(token).getExpiration();
            return exp != null && exp.before(new Date());
        } catch (ExpiredJwtException e) {
            return true;
        }
    }

    public String getSubject(String token) {
        return parse(token).getSubject();
    }

    public long getExpiryEpochMillis(String token) {
        var exp = parse(token).getExpiration();
        return exp != null ? exp.getTime() : 0L;
    }
}
