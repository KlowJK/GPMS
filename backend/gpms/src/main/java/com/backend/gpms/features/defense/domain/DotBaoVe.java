package com.backend.gpms.features.defense.domain;

import com.backend.gpms.common.util.BaseEntity;
import com.backend.gpms.features.council.domain.HoiDong;
import com.backend.gpms.features.topic.domain.DeTai;
import jakarta.persistence.*;
import lombok.Getter; import lombok.Setter;
import lombok.experimental.FieldDefaults;

import java.time.LocalDate;
import java.util.Set;

@Getter @Setter
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
@Entity @Table(name="dot_bao_ve", indexes = @Index(name="idx_dot_khoa", columnList="id_khoa"))
public class DotBaoVe extends BaseEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id;

    @Column(name="ten_dot", nullable=false)
    String tenDot;

    @Column(name="nam_hoc", nullable=false)
    String namHoc;

    @Column(name="hoc_ki", nullable=false)
    String hocKi;

    @Column(name="ngay_bat_dau", nullable=false)
    LocalDate ngayBatDau;

    @Column(name="ngay_ket_thuc", nullable=false)
    LocalDate ngayKetThuc;

    @Column(name="khoa_dot", nullable=false)
    Boolean khoaDot = false;

    @OneToMany(mappedBy = "dotBaoVe")
    Set<ThoiGianThucHien> thoiGianThucHien;

    @OneToMany(mappedBy = "dotBaoVe")
    Set<DeTai> deTaiSet;

    @OneToMany(mappedBy = "dotBaoVe")
    Set<HoiDong> hoiDongBaoVes;

}
