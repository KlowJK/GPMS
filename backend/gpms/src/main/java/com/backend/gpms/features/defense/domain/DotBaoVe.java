package com.backend.gpms.features.defense.domain;

import com.backend.gpms.common.util.BaseEntity;
import com.backend.gpms.features.council.domain.HoiDong;
import com.backend.gpms.features.topic.domain.DeTai;
import jakarta.persistence.*;
import lombok.Getter; import lombok.Setter;
import java.time.LocalDate;
import java.util.Set;

@Getter @Setter
@Entity @Table(name="dot_bao_ve", indexes = @Index(name="idx_dot_khoa", columnList="id_khoa"))
public class DotBaoVe extends BaseEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    @Column(name="ten_dot", nullable=false) private String tenDot;
    @Column(name="nam_hoc", nullable=false) private String namHoc;
    @Column(name="hoc_ki", nullable=false) private String hocKi;
    @Column(name="ngay_bat_dau", nullable=false) private LocalDate ngayBatDau;
    @Column(name="ngay_ket_thuc", nullable=false) private LocalDate ngayKetThuc;
    @Column(name="khoa_dot", nullable=false) private Boolean khoaDot = false;

    @OneToMany(mappedBy = "dotBaoVe")
    Set<ThoiGianThucHien> thoiGianThucHien;

    @OneToMany(mappedBy = "dotBaoVe")
    Set<DeTai> deTaiSet;

    @OneToMany(mappedBy = "dotBaoVe")
    Set<HoiDong> hoiDongBaoVes;

}
