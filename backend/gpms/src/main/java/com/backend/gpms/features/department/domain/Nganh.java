package com.backend.gpms.features.department.domain;
import com.backend.gpms.common.util.BaseEntity;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.util.Set;

@Getter @Setter
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
@Entity @Table(name="nganh", uniqueConstraints = @UniqueConstraint(name="uq_nganh", columnNames={"id_khoa","ma_nganh"}))
public class Nganh extends BaseEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id;

    @Column(name="ten_nganh", nullable=false)
    String tenNganh;

    @Column(name="ma_nganh", nullable=false)
    String maNganh;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name="id_khoa", nullable=false)
    Khoa khoa;

    @OneToMany(mappedBy = "nganh")
    Set<Lop> lopSet;
}