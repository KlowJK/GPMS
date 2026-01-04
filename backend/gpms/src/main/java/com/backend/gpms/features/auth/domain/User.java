package com.backend.gpms.features.auth.domain;


import com.backend.gpms.common.util.BaseEntity;
import com.backend.gpms.features.lecturer.domain.GiangVien;
import com.backend.gpms.features.notification.domain.ThongBaoDen;
import com.backend.gpms.features.student.domain.SinhVien;
import lombok.*;
import lombok.experimental.FieldDefaults;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;


import jakarta.persistence.*;
import java.time.OffsetDateTime;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
@Entity @Table(name="tai_khoan")
public class User extends BaseEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id;

    @Column(nullable = false, unique = true)
    String email;

    @Column(name = "mat_khau", nullable = false)
    String matKhau;

    @Enumerated(EnumType.STRING)
    @Column(name = "vai_tro", nullable = false, columnDefinition = "vai_tro_tk")
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)   // <— quan trọng cho PostgreSQL enum
    Role vaiTro;

    @Column(name = "kich_hoat", nullable = false)
    Boolean trangThaiKichHoat = true;

    @Column(name = "duong_dan_avt")
    String duongDanAvt;

    @OneToOne(mappedBy = "user")
    SinhVien sinhVien;
    @OneToOne(mappedBy = "user")
    GiangVien giangVien;


    @OneToMany(mappedBy = "user")
    List<ThongBaoDen> thongBaoDens;
}
