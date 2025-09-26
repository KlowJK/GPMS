package com.backend.gpms.features.topic.domain;

import jakarta.persistence.*;
import lombok.Getter; import lombok.Setter;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

@Getter @Setter
@Entity @Table(name="de_tai", indexes = {
        @Index(name="idx_dt_gv", columnList="id_giang_vien_huong_dan"),
        @Index(name="idx_dt_dot", columnList="id_dot_bao_ve")
}, uniqueConstraints = @UniqueConstraint(name="uq_dt_sv_dot", columnNames={"id_sinh_vien","id_dot_bao_ve"}))
public class DeTai {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    @Column(name="ten_de_tai", nullable=false) private String tenDeTai;
    @Column(name="mo_ta") private String moTa;
    @Column(name="noi_dung_de_tai") private String noiDungDeTai;
    @Column(name="id_giang_vien_huong_dan", nullable=false) private Long idGiangVienHuongDan;
    @Column(name="id_sinh_vien", nullable=false) private Long idSinhVien;
    @Column(name="id_dot_bao_ve", nullable=false) private Long idDotBaoVe;

    @Enumerated(EnumType.STRING)
    @Column(name="trang_thai", nullable=false, columnDefinition="tt_de_tai")
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    private TrangThaiDeTai trangThai = TrangThaiDeTai.CHO_DUYET;
}
