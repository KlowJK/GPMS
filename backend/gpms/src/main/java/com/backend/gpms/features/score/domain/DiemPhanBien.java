package com.backend.gpms.features.score.domain;

import com.backend.gpms.common.util.BaseEntity;
import com.backend.gpms.features.council.domain.PhanCongPhanBien;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldDefaults;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

@Getter
@Setter
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
@Entity
@Table(name="diem_phan_bien", indexes={
        @Index(name="idx_diem_phan_bien_phan_cong", columnList="id_phan_cong_phan_bien"),
        @Index(name = "idx_diem_phan_bien_trang_thai", columnList = "trang_thai")
        }
)
public class DiemPhanBien extends BaseEntity {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name="id_phan_cong_phan_bien", nullable=false)
    PhanCongPhanBien phanCongPhanBien;

    @Column(name="diem")
    Double diem;

    @Column(name="nhan_xet", columnDefinition="text")
    String nhanXet;


    @Enumerated(EnumType.STRING)
    @Column(name="trang_thai", nullable=false, columnDefinition="tt_diem")
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    TrangThaiDiem trangThai = TrangThaiDiem.CHO_PHE_DUYET;
}
