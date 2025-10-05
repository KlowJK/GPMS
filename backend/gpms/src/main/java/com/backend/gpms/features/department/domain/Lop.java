package com.backend.gpms.features.department.domain;
import com.backend.gpms.common.util.BaseEntity;
import com.backend.gpms.features.student.domain.SinhVien;
import jakarta.persistence.*;
import lombok.*;

import java.util.Set;

@Getter @Setter
@Entity @Table(name="lop", uniqueConstraints = @UniqueConstraint(name="uq_lop", columnNames={"id_nganh","ten_lop"}))
public class Lop extends BaseEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(name="ten_lop", nullable=false)
    private String tenLop;
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name="id_nganh", nullable=false) private Nganh nganh;

    @OneToMany(mappedBy = "lop")
    Set<SinhVien> sinhVienSet;
}