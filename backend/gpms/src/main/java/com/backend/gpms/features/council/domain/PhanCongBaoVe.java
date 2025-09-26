package com.backend.gpms.features.council.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.OffsetDateTime;

@Getter @Setter
@Entity @Table(name="phan_cong_bao_ve", indexes=@Index(name="idx_pcbv_hd", columnList="id_hoi_dong"))
public class PhanCongBaoVe {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    @Column(name="id_hoi_dong", nullable=false) private Long idHoiDong;
    @Column(name="id_de_tai", nullable=false, unique=true) private Long idDeTai;
    @Column(name="id_giang_vien_phan_bien") private Long idGiangVienPhanBien;
    @Column(name="lich_bao_ve") private OffsetDateTime lichBaoVe;
}