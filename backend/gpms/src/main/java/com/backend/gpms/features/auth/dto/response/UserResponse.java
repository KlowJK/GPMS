package com.backend.gpms.features.auth.dto.response;

import com.backend.gpms.features.auth.domain.Role;
import lombok.*;

@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserResponse {
    private Long   id;
    private String fullName;
    private String email;
    private Role   role;
    private String duongDanAvt;
    private Boolean enabled;


    private Long   teacherId;
    private Long   studentId;


    /** Convenience constructor cho trường hợp chỉ có tài khoản cơ bản */
    public UserResponse(Long id, String email, Role vaiTro, Boolean enabled) {
        this.id = id;
        this.email = email;
        this.role = vaiTro;
        this.enabled = enabled;
    }

    /** Factory gọn: nhận dữ liệu đã tra sẵn */
    public static UserResponse of(
            Long id, String fullName,String email, Role role, String duongDanAvt, Boolean enabled,
            Long teacherId, Long studentId
    ) {
        return UserResponse.builder()
                .id(id).fullName(fullName).email(email).role(role).duongDanAvt(duongDanAvt).enabled(enabled)
                .teacherId(teacherId).studentId(studentId)
                .build();
    }
}
