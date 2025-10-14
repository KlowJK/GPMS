package com.backend.gpms.features.score.domain;

import com.backend.gpms.common.util.BaseEntity;
import com.backend.gpms.features.topic.domain.DeTai;
import jakarta.persistence.*;
import org.hibernate.type.SqlTypes;

import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldDefaults;
import org.hibernate.annotations.JdbcTypeCode;

@Getter @Setter
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
@Entity @Table(name="diem", indexes=@Index(name="idx_diem_dt", columnList="id_de_tai"))
public class Diem extends BaseEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name="id_de_tai", nullable=false)
    DeTai deTai;

    @Column(name="diem_bao_cao")
    Double diemBaoCao;

    @Column(name="diem_phan_bien")
    Double diemPhanBien;

    @Column(name="diem_bao_ve")
    Double diemBaoVe;

    @Column(name="diem_tong")
    Double diemTong;

    @Column(name="bien_ban", columnDefinition="text")
    String bienBan;

    @Enumerated(EnumType.STRING)
    @Column(name="trang_thai", nullable=false, columnDefinition="tt_diem")
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    TrangThaiDiem trangThai = TrangThaiDiem.CHO_PHE_DUYET;
}
