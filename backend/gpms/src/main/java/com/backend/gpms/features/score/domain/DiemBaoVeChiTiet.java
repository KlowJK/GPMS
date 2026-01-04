package com.backend.gpms.features.score.domain;


import com.backend.gpms.common.util.BaseEntity;
import com.backend.gpms.features.council.domain.ThanhVienHoiDong;
import com.backend.gpms.features.topic.domain.DeTai;
import jakarta.persistence.*;

import lombok.*;
import lombok.experimental.FieldDefaults;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

@Getter @Setter
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Entity @Table(name="diem_bao_ve_chi_tiet", indexes={
        @Index(name="idx_diem_bao_ve_de_tai", columnList="id_de_tai"),
        @Index(name = "idx_diem_bao_ve_thanh_vien", columnList = "id_thanh_vien_hoi_dong"),
        @Index(name = "idx_diem_bao_ve_hop_le", columnList = "hop_le, trang_thai")
}
)

public class DiemBaoVeChiTiet extends BaseEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name="id_thanh_vien_hoi_dong", nullable=false)
    ThanhVienHoiDong thanhVienHoiDong;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name="id_de_tai", nullable=false)
    DeTai deTai;

    @Column(name="diem")
    Double diem;

    @Column(name="nhan_xet", columnDefinition="text")
    String nhanXet;

    @Enumerated(EnumType.STRING)
    @Column(name="trang_thai", nullable=false, columnDefinition="tt_diem")
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    TrangThaiDiem trangThai;

    @Column(name="hop_le")
    Boolean hopLe = true;
}
