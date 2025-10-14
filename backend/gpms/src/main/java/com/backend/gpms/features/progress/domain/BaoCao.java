package com.backend.gpms.features.progress.domain;
import com.backend.gpms.common.util.BaseEntity;
import com.backend.gpms.features.lecturer.domain.GiangVien;
import com.backend.gpms.features.topic.domain.DeTai;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDate;
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
@Getter @Setter
@Entity @Table(name="bao_cao", indexes=@Index(name="idx_bc_dt", columnList="id_de_tai"))
public class BaoCao extends BaseEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id;

    @ManyToOne(fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @JoinColumn(name="id_de_tai", nullable=false)
    DeTai deTai;

    @Column(name="phien_ban", nullable=false)
    String phienBan;

    @Column(name="duong_dan", nullable=false)
    String duongDan;

    @OneToOne(fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @JoinColumn(name="id_giang_vien_huong_dan")
    GiangVien giangVienHuongDan;

    @Column(name="diem_huong_dan")
    Double diemHuongDan;
}