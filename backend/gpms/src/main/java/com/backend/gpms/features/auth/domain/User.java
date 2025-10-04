package com.backend.gpms.features.auth.domain;


import com.backend.gpms.common.util.BaseEntity;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;


import lombok.Getter;
import lombok.Setter;

import jakarta.persistence.*;
import java.time.OffsetDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity @Table(name="tai_khoan")
public class User extends BaseEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(name = "mat_khau", nullable = false)
    private String matKhau;

    @Enumerated(EnumType.STRING)
    @Column(name = "vai_tro", nullable = false, columnDefinition = "vai_tro_tk")
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)   // <— quan trọng cho PostgreSQL enum
    private Role vaiTro;

    @Column(name = "kich_hoat", nullable = false)
    private Boolean trangThaiKichHoat = true;
}
