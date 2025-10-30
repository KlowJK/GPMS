package com.backend.gpms.features.department.domain;
import com.backend.gpms.common.util.BaseEntity;
import com.backend.gpms.features.auth.domain.User;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;


@Getter @Setter
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
@Entity @Table(name="tro_ly_khoa")
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class TroLyKhoa extends BaseEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id;

    @Column(name="ho_ten", nullable=false)
    String hoTen;

    @Column(name="so_dien_thoai")
    String soDienThoai;

    @Column(name="dia_chi")
    String diaChi;

    @OneToOne
    @JoinColumn(name="id_tai_khoan", nullable=false, unique=true)
    User user;
}