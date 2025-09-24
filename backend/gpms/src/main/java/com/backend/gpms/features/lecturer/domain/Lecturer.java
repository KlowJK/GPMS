package com.backend.gpms.features.lecturer.domain;

import com.backend.gpms.features.auth.domain.User;
import jakarta.persistence.*;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity @Table(name = "giang_vien", uniqueConstraints = @UniqueConstraint(name = "uk_gv_ma", columnNames = "ma_giang_vien"))
public class Lecturer {
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
    @Column(name="id_bo_mon", nullable=false)
    private Long idBoMon;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name="id_tai_khoan", unique = true)
    private User user;

    @Column(name="quota_huong_dan", nullable=false)
    private Integer quotaInstruct = 0;

}
