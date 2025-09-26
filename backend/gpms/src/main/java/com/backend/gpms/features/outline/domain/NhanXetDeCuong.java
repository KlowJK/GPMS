package com.backend.gpms.features.outline.domain;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name="nhan_xet_de_cuong", indexes = @Index(name="idx_nxdc_dc", columnList="id_de_cuong"))
public class NhanXetDeCuong {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    @Column(name="id_de_cuong", nullable=false) private Long idDeCuong;
    @Column(name="nhan_xet", nullable=false, columnDefinition="text") private String nhanXet;
    @Column(name="id_giang_vien", nullable=false) private Long idGiangVien;
}
