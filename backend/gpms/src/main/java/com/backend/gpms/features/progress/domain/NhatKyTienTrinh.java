package com.backend.gpms.features.progress.domain;
import jakarta.persistence.*;
import lombok.Getter; import lombok.Setter;
import java.time.LocalDate;

@Getter @Setter
@Entity @Table(name="nhat_ky_tien_trinh", indexes=@Index(name="idx_nktt_dt", columnList="id_de_tai"))
public class NhatKyTienTrinh {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    @Column(name="id_de_tai", nullable=false) private Long idDeTai;
    @Column(name="tuan", nullable=false) private String tuan;
    @Column(name="noi_dung", nullable=false, columnDefinition="text") private String noiDung;
    @Column(name="ngay_cap_nhat", nullable=false) private LocalDate ngayCapNhat;
    @Column(name="id_giang_vien_huong_dan") private Long idGiangVienHuongDan;
    @Column(name="nhan_xet", columnDefinition="text") private String nhanXet;
}