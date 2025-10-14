package com.backend.gpms.features.council.domain;

import com.backend.gpms.common.util.BaseEntity;
import com.backend.gpms.features.defense.domain.DotBaoVe;
import com.backend.gpms.features.lecturer.domain.GiangVien;
import com.backend.gpms.features.topic.domain.DeTai;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldDefaults;

import java.time.LocalDate;
import java.util.Set;

@Getter @Setter
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
@Entity @Table(name="hoi_dong_bao_ve", indexes=@Index(name="idx_hd_dot", columnList="id_dot_bao_ve"))
public class HoiDong extends BaseEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name="id_dot_bao_ve", nullable=false)
    DotBaoVe dotBaoVe;

    @Column(name="ten_hoi_dong", nullable=false)
    String tenHoiDong;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name="id_chu_tich")
    GiangVien chuTich;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name="id_thu_ky")
    GiangVien thuKy;

    @Column(name="thoi_gian_bat_dau")
    LocalDate thoiGianBatDau;

    @Column(name="thoi_gian_ket_thuc")
    LocalDate thoiGianKetThuc;

    @ManyToMany
    @JoinTable(
            name = "phan_cong_bao_ve",
            joinColumns = @JoinColumn(name = "id_hoi_dong"),
            inverseJoinColumns = @JoinColumn(name = "id_de_tai")
    )
    Set<DeTai> deTaiSet;

    @OneToMany(mappedBy = "hoiDong")
    Set<ThanhVienHoiDong> thanhVienHoiDongSet;
}