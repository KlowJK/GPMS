package com.backend.gpms.features.department.domain;
import com.backend.gpms.common.util.BaseEntity;
import com.backend.gpms.features.lecturer.domain.GiangVien;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.util.Set;

@Getter @Setter
@FieldDefaults(level = AccessLevel.PRIVATE)
@Entity @Table(name="bo_mon", uniqueConstraints = @UniqueConstraint(name="uq_bo_mon", columnNames={"id_khoa","ten_bo_mon"}))
public class BoMon extends BaseEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id;

    @Column(name="ten_bo_mon", nullable=false)
    String tenBoMon;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name="id_truong_bo_mon")
    GiangVien truongBoMon;

    @OneToMany(mappedBy = "boMon")
    Set<GiangVien> giangVienSet;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name="id_khoa", nullable=false)
    Khoa khoa;
}