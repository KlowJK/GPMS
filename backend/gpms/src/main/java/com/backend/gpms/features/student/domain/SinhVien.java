package com.backend.gpms.features.student.domain;

import jakarta.persistence.*;
import lombok.Getter; import lombok.Setter;
import java.time.LocalDate;

@Getter @Setter
@Entity @Table(name="sinh_vien", indexes = {
        @Index(name="idx_sv_nganh", columnList="id_nganh"),
        @Index(name="idx_sv_lop", columnList="id_lop")
})
public class SinhVien {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    @Column(name="ho_ten", nullable=false) private String hoTen;
    @Column(name="ma_sinh_vien", nullable=false, unique=true) private String maSinhVien;
    @Column(name="so_dien_thoai") private String soDienThoai;
    @Column(name="duong_dan_cv") private String duongDanCv;
    @Column(name="ngay_sinh") private LocalDate ngaySinh;
    @Column(name="dia_chi") private String diaChi;
    @Column(name="id_nganh", nullable=false) private Long idNganh;
    @Column(name="id_lop") private Long idLop;
    @Column(name="id_tai_khoan", unique=true) private Long idTaiKhoan;
    @Column(name="du_dieu_kien", nullable=false) private Boolean duDieuKien = false;
}
