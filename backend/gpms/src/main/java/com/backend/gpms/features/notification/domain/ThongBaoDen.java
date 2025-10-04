package com.backend.gpms.features.notification.domain;

import com.backend.gpms.common.util.BaseEntity;
import jakarta.persistence.*;
import lombok.*;


@Getter @Setter
@Entity @Table(name="thong_bao_den",
        uniqueConstraints=@UniqueConstraint(name="uq_tb_den", columnNames={"id_thong_bao","id_nguoi_dung"}),
        indexes=@Index(name="idx_tbd_nd", columnList="id_nguoi_dung"))
public class ThongBaoDen extends BaseEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    @Column(name="id_thong_bao", nullable=false) private Long idThongBao;
    @Column(name="id_nguoi_dung", nullable=false) private Long idNguoiDung; // → tai_khoan.id
}