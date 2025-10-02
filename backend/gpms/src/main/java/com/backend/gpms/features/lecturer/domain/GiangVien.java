package com.backend.gpms.features.lecturer.domain;

import com.backend.gpms.features.auth.domain.User;
import com.backend.gpms.features.department.domain.BoMon;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity @Table(name = "giang_vien", uniqueConstraints = @UniqueConstraint(name = "uk_gv_ma", columnNames = "ma_giang_vien"))
public class GiangVien {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name="ho_ten", nullable=false)
    private String hoTen;

    @Column(name="ma_giang_vien", nullable=false, unique=true)
    private String maGiangVien;

    @Column(name="so_dien_thoai")
    private String soDienThoai;

    @Column(name="hoc_ham")
    private String hocHam;

    @Column(name="hoc_vi")
    private String hocVi;

    // Tối giản: dùng id khoá ngoại như schema (có thể đổi sang @ManyToOne BoMon nếu đã có entity)
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name="id_bo_mon", nullable=false)
    private BoMon boMon;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_tai_khoan", referencedColumnName = "id", nullable = false, unique = true)
    private User user;

    @Column(name="quota_huong_dan", nullable=false)
    private Integer quotaInstruct = 0;

    @Column(name = "duong_dan_avt")
    private String duongDanAvt;

    @Column(name = "ngay_sinh" )
    private LocalDate ngaySinh;
}
