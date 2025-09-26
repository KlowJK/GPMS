package com.backend.gpms.features.council.domain;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

@Getter @Setter
@Entity @Table(name="thanh_vien_hoi_dong",
        uniqueConstraints=@UniqueConstraint(name="uq_tvhd", columnNames={"id_hoi_dong","id_giang_vien"}),
        indexes=@Index(name="idx_tvhd_hd", columnList="id_hoi_dong"))
public class ThanhVienHoiDong {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;

    @Enumerated(EnumType.STRING)
    @Column(name="chuc_vu", nullable=false, columnDefinition="chuc_vu_hd")
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    private ChucVuHoiDong chucVu;

    @Column(name="id_hoi_dong", nullable=false) private Long idHoiDong;
    @Column(name="id_giang_vien", nullable=false) private Long idGiangVien;
}