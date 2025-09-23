package com.backend.gpms.features.auth.domain;


import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;


import lombok.Getter;
import lombok.Setter;

import jakarta.persistence.*;
import java.time.OffsetDateTime;

@Getter
@Setter
@Entity @Table(name="tai_khoan")
public class User {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(name = "mat_khau", nullable = false)
    private String password;

    @Column(name = "so_dien_thoai")
    private String phoneNumber;

    @Enumerated(EnumType.STRING)
    @Column(name = "vai_tro", nullable = false, columnDefinition = "vai_tro_tk")
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)   // <— quan trọng cho PostgreSQL enum
    private Role role;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt = OffsetDateTime.now();

    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt = OffsetDateTime.now();

    @Column(name = "kich_hoat", nullable = false)
    private Boolean enabled = true;
}
