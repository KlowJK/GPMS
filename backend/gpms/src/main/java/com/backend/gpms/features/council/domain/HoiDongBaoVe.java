package com.backend.gpms.features.council.domain;

import jakarta.persistence.*;
import lombok.Getter; import lombok.Setter;


@Getter @Setter
@Entity @Table(name="hoi_dong_bao_ve", indexes=@Index(name="idx_hd_dot", columnList="id_dot_bao_ve"))
public class HoiDongBaoVe {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    @Column(name="id_dot_bao_ve", nullable=false) private Long idDotBaoVe;
    @Column(name="ten_hoi_dong", nullable=false) private String tenHoiDong;
    @Column(name="id_chu_tich") private Long idChuTich;
    @Column(name="id_thu_ky") private Long idThuKy;
}