package com.backend.gpms.features.council.domain;

import com.backend.gpms.common.util.BaseEntity;
import com.backend.gpms.features.lecturer.domain.GiangVien;
import jakarta.persistence.*;
import lombok.*;

@Getter @Setter
@Entity @Table(name="thanh_vien_hoi_dong",
        uniqueConstraints=@UniqueConstraint(name="uq_tvhd", columnNames={"id_hoi_dong","id_giang_vien"}),
        indexes=@Index(name="idx_tvhd_hd", columnList="id_hoi_dong"))
public class ThanhVienHoiDong extends BaseEntity {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name="id_hoi_dong", nullable=false)
    private HoiDong hoiDong;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name="id_giang_vien", nullable=false)
    private GiangVien giangVien;

}