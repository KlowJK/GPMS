package com.backend.gpms.common.security;

import com.backend.gpms.common.exception.ApplicationException;
import com.backend.gpms.common.exception.ErrorCode;
import com.backend.gpms.features.auth.infra.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.*;
import org.springframework.stereotype.Service;

import java.util.Set;

@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {

    private final UserRepository userRepo;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        var u = userRepo.findByEmail(username)
                .orElseThrow(() -> new ApplicationException(ErrorCode.USER_NOT_FOUND));

        var authorities = Set.of(new SimpleGrantedAuthority("ROLE_" + u.getVaiTro().name()));

        // dùng disabled() thay vì accountLocked() cho đúng semantics trạng thái kích hoạt
        return org.springframework.security.core.userdetails.User
                .withUsername(u.getEmail())
                .password(u.getMatKhau())
                .authorities(authorities)
                .disabled(!Boolean.TRUE.equals(u.getTrangThaiKichHoat()))
                .accountExpired(false)
                .accountLocked(false)
                .credentialsExpired(false)
                .build();
    }
}
