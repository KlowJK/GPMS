package com.backend.gpms.features.auth.dto;

import com.backend.gpms.features.auth.domain.Role;
import lombok.*;

@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserResponse {
    private Long   id;           // tai_khoan.id
    private String email;        // tai_khoan.email
    private String phoneNumber;  // tai_khoan.so_dien_thoai
    private Role   role;         // tai_khoan.vai_tro
    private Boolean enabled;     // tai_khoan.kich_hoat

    private Long   teacherId;    // giang_vien.id (nullable)
    private Long   studentId;    // sinh_vien.id (nullable)
    private String fullName;     // ho_ten từ giang_vien/sinh_vien (nullable)

    /** Convenience constructor cho trường hợp chỉ có tài khoản cơ bản */
    public UserResponse(Long id, String email, String phoneNumber, Role role, Boolean enabled) {
        this.id = id;
        this.email = email;
        this.phoneNumber = phoneNumber;
        this.role = role;
        this.enabled = enabled;
    }

    /** Factory gọn: nhận dữ liệu đã tra sẵn */
    public static UserResponse of(
            Long id, String email, String phoneNumber, Role role, Boolean enabled,
            Long teacherId, Long studentId, String fullName
    ) {
        return UserResponse.builder()
                .id(id).email(email).phoneNumber(phoneNumber).role(role).enabled(enabled)
                .teacherId(teacherId).studentId(studentId).fullName(fullName)
                .build();
    }
}
