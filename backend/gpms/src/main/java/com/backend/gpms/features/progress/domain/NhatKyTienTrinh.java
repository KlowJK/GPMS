package com.backend.gpms.features.progress.domain;
import com.backend.gpms.common.util.BaseEntity;
import com.backend.gpms.features.lecturer.domain.GiangVien;
import com.backend.gpms.features.topic.domain.DeTai;
import com.backend.gpms.features.topic.domain.TrangThaiDeTai;
import jakarta.persistence.*;
import lombok.Getter; import lombok.Setter;
import lombok.experimental.FieldDefaults;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDateTime;


@Getter @Setter
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
@Entity @Table(name="nhat_ky_tien_trinh", indexes=@Index(name="idx_nktt_dt", columnList="id_de_tai"))
public class NhatKyTienTrinh extends BaseEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id;

    @ManyToOne(fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @JoinColumn(name="id_de_tai", nullable=false)
    DeTai deTai;

    @Column(name="tuan", nullable=false)
    Integer tuan;

    @Column(name="noi_dung", nullable=true, columnDefinition="text")
    String noiDung;

    @Column(name="duong_dan_file", nullable=false)
    String duongDanFile;

    @Enumerated(EnumType.STRING)
    @Column(name="trang_thai_nhat_ky", nullable=false, columnDefinition="trang_thai_nhat_ky")
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
     TrangThaiNhatKy trangThaiNhatKy;

    @OneToOne(fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @JoinColumn(name="id_giang_vien_huong_dan")
    GiangVien giangVienHuongDan;

    @Column(name="nhan_xet", columnDefinition="text")
    String nhanXet;

    @Column(name="ngay_bat_dau", nullable=false)
    LocalDateTime ngayBatDau;

    @Column(name="ngay_ket_thuc", nullable=false)
    LocalDateTime ngayKetThuc;
}
