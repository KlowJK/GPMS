package com.backend.gpms.features.council.domain;

import com.backend.gpms.features.topic.domain.DeTai;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.OffsetDateTime;

@Getter @Setter
@Entity @Table(name="phan_cong_bao_ve", indexes=@Index(name="idx_pcbv_hd", columnList="id_hoi_dong"))
public class PhanCongBaoVe {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name="id_hoi_dong", nullable=false)
    private HoiDongBaoVe idHoiDong;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name="id_de_tai", nullable=false, unique=true)
    private DeTai idDeTai;
}