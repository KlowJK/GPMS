
package com.backend.gpms.features.score.domain;

import com.backend.gpms.common.util.BaseEntity;
import jakarta.persistence.*;

import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldDefaults;
@Getter @Setter
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
@Entity
@Table(name="lich_su_diem", indexes={
        @Index(name = "idx_lich_su_diem_diem", columnList = "id_diem"),
        @Index(name = "idx_lich_su_diem_phan_bien", columnList = "id_diem_phan_bien"),
        @Index(name = "idx_lich_su_diem_bao_ve", columnList = "id_diem_bao_ve_chi_tiet"),
        @Index(name = "idx_lich_su_diem_time", columnList = "created_at"),
        @Index(name = "idx_lich_su_diem_nguoi", columnList = "nguoi_thay_doi")
})
public class LichSuDiem extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_diem")
    Diem diem;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_diem_phan_bien")
    DiemPhanBien diemPhanBien;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_diem_bao_ve_chi_tiet")
    DiemBaoVeChiTiet diemBaoVeChiTiet;

    @Column(name = "thay_doi", columnDefinition = "jsonb")
    String thayDoi;

    @Column(name = "nguoi_thay_doi", columnDefinition = "text", nullable = false)
    String nguoiThayDoi;

    @Column(name = "hanh_dong", columnDefinition = "text", nullable = false)
    String hanhDong;

}