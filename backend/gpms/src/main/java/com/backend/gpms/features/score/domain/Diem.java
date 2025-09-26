package com.backend.gpms.features.score.domain;


import jakarta.persistence.*;
import lombok.Getter; import lombok.Setter;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

@Getter @Setter
@Entity @Table(name="diem", indexes=@Index(name="idx_diem_dt", columnList="id_de_tai"))
public class Diem {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    @Column(name="id_de_tai", nullable=false) private Long idDeTai;
    @Column(name="diem_de_cuong") private Double diemDeCuong;
    @Column(name="diem_phan_bien") private Double diemPhanBien;
    @Column(name="diem_bao_ve") private Double diemBaoVe;
    @Column(name="diem_tong") private Double diemTong;
    @Column(name="bien_ban", columnDefinition="text") private String bienBan;

    @Enumerated(EnumType.STRING)
    @Column(name="trang_thai", nullable=false, columnDefinition="tt_diem")
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    private TrangThaiDiem trangThai = TrangThaiDiem.CHO_PHE_DUYET;
}
