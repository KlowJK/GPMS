package com.backend.gpms.features.progress.domain;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;

@Getter @Setter
@Entity @Table(name="bao_cao", indexes=@Index(name="idx_bc_dt", columnList="id_de_tai"))
public class BaoCao {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    @Column(name="id_de_tai", nullable=false) private Long idDeTai;
    @Column(name="phien_ban", nullable=false) private String phienBan;
    @Column(name="duong_dan", nullable=false) private String duongDan;
    @Column(name="ngay_nop", nullable=false) private LocalDate ngayNop;
    @Column(name="id_giang_vien_huong_dan") private Long idGiangVienHuongDan;
    @Column(name="diem_huong_dan") private Double diemHuongDan;
}