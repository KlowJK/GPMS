package com.backend.gpms.features.council.domain;

import com.backend.gpms.common.util.BaseEntity;
import com.backend.gpms.features.defense.domain.DotBaoVe;
import com.backend.gpms.features.lecturer.domain.GiangVien;
import jakarta.persistence.*;
import lombok.Getter; import lombok.Setter;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.Date;


@Getter @Setter
@Entity @Table(name="hoi_dong_bao_ve", indexes=@Index(name="idx_hd_dot", columnList="id_dot_bao_ve"))
public class HoiDongBaoVe extends BaseEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name="id_dot_bao_ve", nullable=false)
    private DotBaoVe dotBaoVe;

    @Column(name="ten_hoi_dong", nullable=false) private String tenHoiDong;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name="id_chu_tich")
    private GiangVien chuTich;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name="id_thu_ky")
    private GiangVien idThuKy;

    @Column(name="thoi_gian_bat_dau") private LocalDate thoiGianBatDau;

    @Column(name="thoi_gian_ket_thuc") private  LocalDate thoiGianKetThuc;
}