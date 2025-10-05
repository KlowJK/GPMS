package com.backend.gpms.features.department.domain;
import com.backend.gpms.common.util.BaseEntity;
import jakarta.persistence.*;
import lombok.*;

import java.util.Set;

@Getter @Setter
@Entity @Table(name="nganh", uniqueConstraints = @UniqueConstraint(name="uq_nganh", columnNames={"id_khoa","ma_nganh"}))
public class Nganh extends BaseEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    @Column(name="ten_nganh", nullable=false) private String tenNganh;
    @Column(name="ma_nganh", nullable=false) private String maNganh;
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name="id_khoa", nullable=false) private Khoa khoa;

    @OneToMany(mappedBy = "nganh")
    Set<Lop> lopSet;
}