package com.backend.gpms.common.security;

import com.backend.gpms.common.exception.ApplicationException;
import com.backend.gpms.common.exception.ErrorCode;
import com.backend.gpms.common.util.HashUtils;
import com.backend.gpms.features.auth.domain.TokenPurpose;
import com.backend.gpms.features.auth.infra.TokenBlacklistRepository;
import io.jsonwebtoken.JwtException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;


import java.io.IOException;
import java.util.List;

@Component
@RequiredArgsConstructor
public class JwtAuthFilter extends OncePerRequestFilter {

    private final JwtUtils jwt;
    private final CustomUserDetailsService uds;
    private final TokenBlacklistRepository tokenBlacklistRepo;

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String path = request.getRequestURI();
        if (HttpMethod.OPTIONS.matches(request.getMethod())) return true; // Preflight
        return
                path.startsWith("/v3/api-docs") ||
                path.startsWith("/swagger-ui");
    }

    @Override
    protected void doFilterInternal(HttpServletRequest req, HttpServletResponse res,
                                    FilterChain chain) throws ServletException, IOException {
        if (SecurityContextHolder.getContext().getAuthentication() == null) {
            String auth = req.getHeader("Authorization");
            if (auth != null && auth.startsWith("Bearer ")) {
                String token = auth.substring(7);
                try {
                    // Kiểm tra token trong blacklist
                    String tokenHash = HashUtils.sha256(token);
                    if (tokenBlacklistRepo.existsByTokenHashAndPurposeIn(
                            tokenHash, List.of(TokenPurpose.LOGOUT, TokenPurpose.CHANGE_PASSWORD))) {
                        throw new ApplicationException(ErrorCode.INVALID_TOKEN);
                    }

                    // Kiểm tra token hết hạn và xác thực
                    if (!jwt.isExpired(token)) {
                        String username = jwt.getSubject(token);
                        if (username != null && !username.isBlank()) {
                            UserDetails user = uds.loadUserByUsername(username);
                            var authToken = new UsernamePasswordAuthenticationToken(
                                    user, null, user.getAuthorities());
                            authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(req));
                            SecurityContextHolder.getContext().setAuthentication(authToken);
                        }
                    } else {
                        throw new ApplicationException(ErrorCode.TOKEN_EXPIRED);
                    }
                } catch (JwtException e) {
                    throw new ApplicationException(ErrorCode.INVALID_TOKEN);
                } catch (UsernameNotFoundException e) {
                    throw new ApplicationException(ErrorCode.USER_NOT_FOUND);
                }
            }
        }
        chain.doFilter(req, res);
    }
}