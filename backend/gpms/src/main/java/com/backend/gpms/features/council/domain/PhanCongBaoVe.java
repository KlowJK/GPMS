package com.backend.gpms.features.council.domain;

import com.backend.gpms.common.util.BaseEntity;
import com.backend.gpms.features.topic.domain.DeTai;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldDefaults;

@Getter @Setter
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
@Entity @Table(name="phan_cong_bao_ve", indexes=@Index(name="idx_pcbv_hd", columnList="id_hoi_dong"))
public class PhanCongBaoVe extends BaseEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name="id_hoi_dong", nullable=false)
    HoiDong hoiDongBaoVe;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name="id_de_tai", nullable=false, unique=true)
    DeTai deTai;
}