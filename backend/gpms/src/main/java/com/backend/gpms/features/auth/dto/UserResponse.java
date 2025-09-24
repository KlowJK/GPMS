package com.backend.gpms.features.auth.dto;
import com.backend.gpms.features.auth.domain.Role;

import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
public class UserResponse {
    private Long id;
    private String email;
    private String phoneNumber;
    private Role role;
    private Boolean enabled;

    public UserResponse(Long id, String email,String phoneNumber, Role role, Boolean enabled) {
        this.id = id;
        this.email = email;
        this.phoneNumber = phoneNumber;
        this.role = role;
        this.enabled = enabled;
    }

}
