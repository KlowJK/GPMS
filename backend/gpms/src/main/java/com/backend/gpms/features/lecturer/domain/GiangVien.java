package com.backend.gpms.features.lecturer.domain;

import com.backend.gpms.common.util.BaseEntity;
import com.backend.gpms.features.auth.domain.User;
import com.backend.gpms.features.department.domain.BoMon;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
@Entity @Table(name = "giang_vien", uniqueConstraints = @UniqueConstraint(name = "uk_gv_ma", columnNames = "ma_giang_vien"))
public class GiangVien extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id;

    @Column(name="ho_ten", nullable=false)
    String hoTen;

    @Column(name="ma_giang_vien", nullable=false, unique=true)
    String maGiangVien;

    @Column(name="so_dien_thoai")
    String soDienThoai;

    @Column(name="hoc_ham")
    String hocHam;

    @Column(name="hoc_vi")
    String hocVi;

    // Tối giản: dùng id khoá ngoại như schema (có thể đổi sang @ManyToOne BoMon nếu đã có entity)
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name="id_bo_mon", nullable=false)
    BoMon boMon;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_tai_khoan", referencedColumnName = "id", nullable = false, unique = true)
    User user;

    @Column(name="quota_huong_dan", nullable=false)
    Integer quotaInstruct = 0;

    @Column(name = "duong_dan_avt")
    String duongDanAvt;

    @Column(name = "ngay_sinh" )
    LocalDate ngaySinh;

    @OneToOne(mappedBy = "truongBoMon")
    BoMon boMonQuanLy;
}
