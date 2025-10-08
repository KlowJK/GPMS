package com.backend.gpms.features.student.domain;

import com.backend.gpms.common.util.BaseEntity;
import com.backend.gpms.features.auth.domain.User;
import com.backend.gpms.features.department.domain.Lop;
import com.backend.gpms.features.topic.domain.DeTai;
import com.backend.gpms.features.topic.domain.DonHoanDoAn;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Getter @Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Entity @Table(name="sinh_vien", indexes = {
        @Index(name="idx_sv_nganh", columnList="id_nganh"),
        @Index(name="idx_sv_lop", columnList="id_lop")
})
public class SinhVien extends BaseEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    @Column(name="ho_ten", nullable=false) private String hoTen;
    @Column(name="ma_sinh_vien", nullable=false, unique=true) private String maSinhVien;
    @Column(name="so_dien_thoai") private String soDienThoai;
    @Column(name="duong_dan_cv") private String duongDanCv;
    @Column(name="ngay_sinh") private LocalDate ngaySinh;
    @Column(name="dia_chi") private String diaChi;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name="id_lop")
    private Lop lop;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_tai_khoan", referencedColumnName = "id", nullable = false, unique = true)
    private User user;

    @Column(name="du_dieu_kien", nullable=false) private Boolean duDieuKien = false;

    @Column(name = "duong_dan_avt")
    private String duongDanAvt;

    @OneToOne(mappedBy = "sinhVien")
    private DeTai deTai;

    @OneToMany(mappedBy = "sinhVien", fetch = FetchType.LAZY)
    List<DonHoanDoAn> donHoanList = new ArrayList<>();

}
