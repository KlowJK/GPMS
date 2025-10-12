package com.backend.gpms.features.progress.domain;
import com.backend.gpms.common.util.BaseEntity;
import com.backend.gpms.features.lecturer.domain.GiangVien;
import com.backend.gpms.features.topic.domain.DeTai;
import com.backend.gpms.features.topic.domain.TrangThaiDeTai;
import jakarta.persistence.*;
import lombok.Getter; import lombok.Setter;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDateTime;


@Getter @Setter
@Entity @Table(name="nhat_ky_tien_trinh", indexes=@Index(name="idx_nktt_dt", columnList="id_de_tai"))
public class NhatKyTienTrinh extends BaseEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;

    @ManyToOne(fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @JoinColumn(name="id_de_tai", nullable=false) private DeTai deTai;

    @Column(name="tuan", nullable=false) private String tuan;

    @Column(name="noi_dung", nullable=false, columnDefinition="text") private String noiDung;

    @Column(name="duong_dan_file", nullable=false) private String duongDanFile;

    @Enumerated(EnumType.STRING)
    @Column(name="trang_thai_nhat_ky", nullable=false, columnDefinition="tt_duyet_don")
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    private TrangThaiDeTai trangThaiNhatKy;

    @OneToOne(fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @JoinColumn(name="id_giang_vien_huong_dan") private GiangVien giangVienHuongDan;
    @Column(name="nhan_xet", columnDefinition="text") private String nhanXet;

    @Column(name="ngay_bat_dau", nullable=false) private LocalDateTime ngayBatDau;
    @Column(name="ngay_ket_thuc", nullable=false) private LocalDateTime ngayKetThuc;
}
