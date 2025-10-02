package com.backend.gpms.common.security;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.*;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.*;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.*;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.*;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.*;

import jakarta.servlet.http.HttpServletResponse;
import java.util.List;

@Configuration
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthFilter jwtFilter;
    private final UserDetailsService uds;

    @Bean PasswordEncoder passwordEncoder() { return new BCryptPasswordEncoder(); }

    @Bean
    AuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider p = new DaoAuthenticationProvider();
        p.setUserDetailsService(uds);
        p.setPasswordEncoder(passwordEncoder());
        return p;
    }

    @Bean
    AuthenticationManager authenticationManager(AuthenticationConfiguration cfg) throws Exception {
        return cfg.getAuthenticationManager();
    }

    @Bean
    SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
                .csrf(csrf -> csrf.disable())
                .cors(Customizer.withDefaults())
                .sessionManagement(sm -> sm.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .exceptionHandling(ex -> ex
                        .authenticationEntryPoint((req, res, e) -> {
                            res.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                            res.setContentType("application/json;charset=UTF-8");
                            res.getWriter().write("{\"error\":\"UNAUTHORIZED\",\"message\":\"Bạn cần đăng nhập.\"}");
                        })
                        .accessDeniedHandler((req, res, e) -> {
                            res.setStatus(HttpServletResponse.SC_FORBIDDEN);
                            res.setContentType("application/json;charset=UTF-8");
                            res.getWriter().write("{\"error\":\"FORBIDDEN\",\"message\":\"Không có quyền truy cập.\"}");
                        })
                )
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                        .requestMatchers("/api/auth/**",
                                "/v3/api-docs/**",
                                "/swagger-ui/**",
                                "/swagger-ui.html").permitAll()
                        .requestMatchers(HttpMethod.GET, "/api/public/**", "/actuator/**").permitAll()
                        .anyRequest().authenticated()
                )
                .authenticationProvider(authenticationProvider())
                .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    // CORS DEV cho Flutter/React local
    @Bean
    CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration conf = new CorsConfiguration();
        conf.setAllowedOriginPatterns(List.of(
                "http://localhost:*",
                "http://127.0.0.1:*"
        ));
        conf.setAllowedMethods(List.of("GET","POST","PUT","PATCH","DELETE","OPTIONS"));
        conf.setAllowedHeaders(List.of("Authorization","Content-Type","Accept","X-Requested-With","Origin"));
        conf.setExposedHeaders(List.of("Authorization"));
        conf.setAllowCredentials(false); // JWT qua header
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", conf);
        return source;
    }
}
