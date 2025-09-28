package com.backend.gpms.features.auth.dto.response;

import com.backend.gpms.features.auth.domain.Role;
import lombok.*;

@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserResponse {
    private Long   id;
    private String email;
    private String soDienThoai;
    private Role   vaiTro;
    private Boolean enabled;

    private Long   teacherId;
    private Long   studentId;
    private String fullName;

    /** Convenience constructor cho trường hợp chỉ có tài khoản cơ bản */
    public UserResponse(Long id, String email, String soDienThoai, Role vaiTro, Boolean enabled) {
        this.id = id;
        this.email = email;
        this.soDienThoai = soDienThoai;
        this.vaiTro = vaiTro;
        this.enabled = enabled;
    }

    /** Factory gọn: nhận dữ liệu đã tra sẵn */
    public static UserResponse of(
            Long id, String email, String soDienThoai, Role vaiTro, Boolean enabled,
            Long teacherId, Long studentId, String fullName
    ) {
        return UserResponse.builder()
                .id(id).email(email).soDienThoai(soDienThoai).vaiTro(vaiTro).enabled(enabled)
                .teacherId(teacherId).studentId(studentId).fullName(fullName)
                .build();
    }
}
