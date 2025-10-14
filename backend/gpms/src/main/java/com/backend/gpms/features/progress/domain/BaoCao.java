package com.backend.gpms.features.progress.domain;
import com.backend.gpms.common.util.BaseEntity;
import com.backend.gpms.features.lecturer.domain.GiangVien;
import com.backend.gpms.features.outline.domain.TrangThaiDuyetDon;
import com.backend.gpms.features.topic.domain.DeTai;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

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
    Integer phienBan;

    @Column(name="duong_dan", nullable=false)
    String duongDanFile;

    @OneToOne(fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @JoinColumn(name="id_giang_vien_huong_dan")
    GiangVien giangVienHuongDan;

    @Column(name="diem_huong_dan")
    Double diemHuongDan;

    @Column(name="ghi_chu")
    String ghiChu;

    @Enumerated(EnumType.STRING)
    @Column(name="trang_thai_bao_cao", nullable=false, columnDefinition="tt_")
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    TrangThaiDuyetDon trangThai = TrangThaiDuyetDon.CHO_DUYET;
}