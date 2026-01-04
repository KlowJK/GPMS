package com.backend.gpms.features.outline.domain;

import com.backend.gpms.common.util.BaseEntity;
import com.backend.gpms.features.lecturer.domain.GiangVien;
import com.backend.gpms.features.topic.domain.DeTai;
import jakarta.persistence.*;
import lombok.Getter; import lombok.Setter;
import lombok.experimental.FieldDefaults;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import java.time.LocalDate;
import java.util.List;

@Getter @Setter
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
@Entity @Table(name="de_cuong", indexes = @Index(name="idx_dc_dt", columnList="id_de_tai"))
public class DeCuong extends BaseEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name="id_de_tai", nullable=false)
    DeTai deTai;

    @Column(name="phien_ban", nullable=false)
    int phienBan;

    @Column(name="duong_dan_file", nullable=false)
    String duongDanFile;


    @OneToOne(fetch =  FetchType.LAZY, cascade = CascadeType.ALL)
    @JoinColumn(name="id_giang_vien_huong_dan")
    GiangVien giangVienHuongDan;

    @OneToOne(fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @JoinColumn(name="id_giang_vien_phan_bien")
    GiangVien giangVienPhanBien;


    @OneToOne(fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @JoinColumn (name="id_truong_bo_mon")
    GiangVien truongBoMon;

    @Enumerated(EnumType.STRING)
    @Column(name="trang_thai_de_cuong", nullable=false, columnDefinition="tt_de_cuong")
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    TrangThaiDeCuong trangThaiDeCuong = TrangThaiDeCuong.CHO_DUYET;

    @Enumerated(EnumType.STRING)
    @Column(name="gv_phan_bien_duyet", columnDefinition="tt_duyet_don")
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    TrangThaiDuyetDon gvPhanBienDuyet;

    @Enumerated(EnumType.STRING)
    @Column(name="tbm_duyet", columnDefinition="tt_duyet_don")
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    TrangThaiDuyetDon tbmDuyet;

    @OneToMany(mappedBy = "deCuong", cascade = CascadeType.ALL, orphanRemoval = true)
    List<NhanXetDeCuong> nhanXets;
}

