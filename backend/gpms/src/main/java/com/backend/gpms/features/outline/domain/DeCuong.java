package com.backend.gpms.features.outline.domain;

import jakarta.persistence.*;
import lombok.Getter; import lombok.Setter;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import java.time.LocalDate;

@Getter @Setter
@Entity @Table(name="de_cuong", indexes = @Index(name="idx_dc_dt", columnList="id_de_tai"))
public class DeCuong {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    @Column(name="id_de_tai", nullable=false) private Long idDeTai;
    @Column(name="phien_ban", nullable=false) private String phienBan;
    @Column(name="duong_dan_file", nullable=false) private String duongDanFile;
    @Column(name="ngay_nop", nullable=false) private LocalDate ngayNop;
    @Column(name="id_giang_vien_huong_dan") private Long idGiangVienHuongDan;
    @Column(name="id_giang_vien_phan_bien") private Long idGiangVienPhanBien;
    @Column(name="id_truong_bo_mon") private Long idTruongBoMon;

    @Enumerated(EnumType.STRING)
    @Column(name="trang_thai_de_cuong", nullable=false, columnDefinition="tt_de_cuong")
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    private TrangThaiDeCuong trangThaiDeCuong = TrangThaiDeCuong.CHO_DUYET;

    @Enumerated(EnumType.STRING)
    @Column(name="gv_phan_bien_duyet", columnDefinition="tt_duyet_don")
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    private TrangThaiDuyetDon gvPhanBienDuyet;

    @Enumerated(EnumType.STRING)
    @Column(name="tbm_duyet", columnDefinition="tt_duyet_don")
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    private TrangThaiDuyetDon tbmDuyet;
}

