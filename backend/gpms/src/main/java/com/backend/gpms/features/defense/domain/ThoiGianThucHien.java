package com.backend.gpms.features.defense.domain;

import com.backend.gpms.common.util.BaseEntity;
import com.backend.gpms.features.topic.domain.DeTai;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDate;

@Getter
@Setter
@Entity
@Table(name="thoi_gian_thuc_hien", indexes = @Index(name="idx_tgth_dbv", columnList="id_dot_bao_ve"))
public class ThoiGianThucHien extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name="cong_viec", nullable=false) private CongViec congViec;

    @Column(name="thoi_gian_bat_dau", nullable=false) private LocalDate thoiGianBatDau;
    @Column(name="thoi_gian_ket_thuc", nullable=false) private LocalDate thoiGianKetThuc;
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name="id_dot_bao_ve", nullable=false)
    private DotBaoVe dotBaoVe;
}
