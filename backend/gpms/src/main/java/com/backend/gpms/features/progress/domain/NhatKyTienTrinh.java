package com.backend.gpms.features.progress.domain;
import com.backend.gpms.features.lecturer.domain.GiangVien;
import com.backend.gpms.features.topic.domain.DeTai;
import jakarta.persistence.*;
import lombok.Getter; import lombok.Setter;
import java.time.LocalDate;

@Getter @Setter
@Entity @Table(name="nhat_ky_tien_trinh", indexes=@Index(name="idx_nktt_dt", columnList="id_de_tai"))
public class NhatKyTienTrinh {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;

    @ManyToOne(fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @JoinColumn(name="id_de_tai", nullable=false) private DeTai idDeTai;
    @Column(name="tuan", nullable=false) private String tuan;
    @Column(name="noi_dung", nullable=false, columnDefinition="text") private String noiDung;
    @Column(name="ngay_cap_nhat", nullable=false) private LocalDate ngayCapNhat;
    @OneToOne(fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @JoinColumn(name="id_giang_vien_huong_dan") private GiangVien idGiangVienHuongDan;
    @Column(name="nhan_xet", columnDefinition="text") private String nhanXet;
}