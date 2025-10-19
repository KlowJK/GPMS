package com.backend.gpms.features.topic.domain;

import com.backend.gpms.common.util.BaseEntity;
import com.backend.gpms.features.defense.domain.DotBaoVe;
import com.backend.gpms.features.department.domain.BoMon;
import com.backend.gpms.features.lecturer.domain.GiangVien;
import com.backend.gpms.features.progress.domain.NhatKyTienTrinh;
import com.backend.gpms.features.student.domain.SinhVien;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.util.List;

@Getter @Setter
@Builder
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
@Entity @Table(name="de_tai", indexes = {
        @Index(name="idx_dt_gv", columnList="id_giang_vien_huong_dan"),
        @Index(name="idx_dt_dot", columnList="id_dot_bao_ve"),
        @Index(name = "idx_dt_bo_mon", columnList = "id_bo_mon")
}, uniqueConstraints = @UniqueConstraint(name="uq_dt_sv_dot", columnNames={"id_sinh_vien","id_dot_bao_ve"}))
@NoArgsConstructor
@AllArgsConstructor
public class DeTai extends BaseEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id;

    @Column(name="ten_de_tai", nullable=false)
    String tenDeTai;

    @Column(name="noi_dung_de_tai")
    String noiDungDeTaiUrl;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name="id_giang_vien_huong_dan", nullable=false)
    GiangVien giangVienHuongDan;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name="id_sinh_vien", nullable=false)
    SinhVien sinhVien;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name="id_dot_bao_ve", nullable=false)
    DotBaoVe dotBaoVe;

    @Enumerated(EnumType.STRING)
    @Column(name="trang_thai", nullable=false, columnDefinition="tt_de_tai")
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    TrangThaiDeTai trangThai = TrangThaiDeTai.CHO_DUYET;

    @Column(name="nhan_xet")
    String nhanXet;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name="id_bo_mon", nullable=false)
    BoMon boMon;

    @OneToMany(mappedBy = "deTai", cascade = CascadeType.ALL, orphanRemoval = true)
    List<NhatKyTienTrinh> nhatKyTienTrinhs;

}
