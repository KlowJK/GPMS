package com.backend.gpms.features.department.domain;
import com.backend.gpms.common.util.BaseEntity;
import com.backend.gpms.features.lecturer.domain.GiangVien;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.util.Set;

@Getter @Setter
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
@Entity @Table(name="khoa")
public class Khoa extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id;

    @Column(name = "ten_khoa", nullable = false, unique = true)
    String tenKhoa;

    @OneToMany(mappedBy = "khoa")
    Set<Nganh> nganhSet;

    @OneToMany(mappedBy = "khoa")
    Set<BoMon> boMonSet;

    @OneToOne
    @JoinColumn(name = "chu_nhiem_khoa", referencedColumnName = "id")
    private GiangVien chuNhiemKhoa;

}