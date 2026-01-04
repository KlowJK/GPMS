package com.backend.gpms.features.student.domain;

import com.backend.gpms.common.util.BaseEntity;
import com.backend.gpms.features.auth.domain.User;
import com.backend.gpms.features.department.domain.Lop;
import com.backend.gpms.features.topic.domain.DeTai;
import com.backend.gpms.features.topic.domain.DonHoanDoAn;
import jakarta.persistence.*;

import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Getter @Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
@Entity @Table(name="sinh_vien", indexes = {
        @Index(name="idx_sv_nganh", columnList="id_nganh"),
        @Index(name="idx_sv_lop", columnList="id_lop")
})
public class SinhVien extends BaseEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id;

    @Column(name="ho_ten", nullable=false)
    String hoTen;

    @Column(name="ma_sinh_vien", nullable=false, unique=true)
    String maSinhVien;

    @Column(name="so_dien_thoai")
    String soDienThoai;

    @Column(name="duong_dan_cv")
    String duongDanCv;

    @Column(name="ngay_sinh")
    LocalDate ngaySinh;

    @Column(name="dia_chi")
    String diaChi;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name="id_lop")
    Lop lop;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_tai_khoan", referencedColumnName = "id", nullable = false, unique = true)
    User user;

    @Column(name="du_dieu_kien", nullable=false) Boolean duDieuKien = false;

    @OneToOne(mappedBy = "sinhVien")
    DeTai deTai;

    @OneToMany(mappedBy = "sinhVien", fetch = FetchType.LAZY)
    List<DonHoanDoAn> donHoanList = new ArrayList<>();

}
