package com.backend.gpms.features.progress.domain;
import com.backend.gpms.common.util.BaseEntity;
import com.backend.gpms.features.lecturer.domain.GiangVien;
import com.backend.gpms.features.topic.domain.DeTai;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;

@Getter @Setter
@Entity @Table(name="bao_cao", indexes=@Index(name="idx_bc_dt", columnList="id_de_tai"))
public class BaoCao extends BaseEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    @ManyToOne(fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @JoinColumn(name="id_de_tai", nullable=false) private DeTai deTai;
    @Column(name="phien_ban", nullable=false) private String phienBan;
    @Column(name="duong_dan", nullable=false) private String duongDan;
    @OneToOne(fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @JoinColumn(name="id_giang_vien_huong_dan") private GiangVien giangVienHuongDan;
    @Column(name="diem_huong_dan") private Double diemHuongDan;
}