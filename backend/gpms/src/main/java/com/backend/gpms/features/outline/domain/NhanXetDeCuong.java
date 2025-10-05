package com.backend.gpms.features.outline.domain;
import com.backend.gpms.common.util.BaseEntity;
import com.backend.gpms.features.lecturer.domain.GiangVien;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name="nhan_xet_de_cuong", indexes = @Index(name="idx_nxdc_dc", columnList="id_de_cuong"))
public class NhanXetDeCuong extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    @ManyToOne(fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @JoinColumn(name="id_de_cuong", nullable=false) private DeCuong deCuong;
    @Column(name="nhan_xet", nullable=false, columnDefinition="text") private String nhanXet;
    @ManyToOne(fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @JoinColumn(name="id_giang_vien", nullable=false) private GiangVien giangVien;
}
