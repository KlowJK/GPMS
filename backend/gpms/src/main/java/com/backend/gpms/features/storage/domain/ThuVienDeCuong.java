package com.backend.gpms.features.storage.domain;
import com.backend.gpms.common.util.BaseEntity;
import com.backend.gpms.features.defense.domain.DotBaoVe;
import jakarta.persistence.*;
import lombok.*;


import lombok.experimental.FieldDefaults;

@Builder
@AllArgsConstructor
@NoArgsConstructor
@Getter @Setter
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
@Entity @Table(name="thu_vien_de_cuong", indexes=@Index(name="thu_vien_de_cuong_pkey", columnList="id"))
public class ThuVienDeCuong extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id;

    @ManyToOne(fetch=FetchType.LAZY)
    @JoinColumn(name="id_thu_vien_de_tai", nullable=false)
    ThuVienDeTai thuVienDeTai;

    @Column(name="duong_dan_file")
    String duongDan;

    @Column(name="phien_ban")
    String phienBan;

}
