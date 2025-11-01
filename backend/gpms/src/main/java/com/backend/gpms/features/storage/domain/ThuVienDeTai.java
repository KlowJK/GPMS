package com.backend.gpms.features.storage.domain;

import com.backend.gpms.features.defense.domain.DotBaoVe;
import jakarta.persistence.*;
import lombok.*;


import lombok.experimental.FieldDefaults;

@Builder
@AllArgsConstructor
@NoArgsConstructor
@Getter @Setter
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
@Entity @Table(name="thu_vien_de_tai", indexes=@Index(name="thu_vien_de_tai_pkey", columnList="id"))
public class ThuVienDeTai {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id;

    @Column(name="ten_de_tai", nullable=false)
    String deTai;

    @Column(name="duong_dan", nullable=false)
    String duongDan;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name="id_dot_bao_ve", nullable=false)
    DotBaoVe dotBaoVe;
}