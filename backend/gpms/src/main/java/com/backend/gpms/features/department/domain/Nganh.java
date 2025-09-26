package com.backend.gpms.features.department.domain;
import jakarta.persistence.*;
import lombok.*;

@Getter @Setter
@Entity @Table(name="nganh", uniqueConstraints = @UniqueConstraint(name="uq_nganh", columnNames={"id_khoa","ma_nganh"}))
public class Nganh {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    @Column(name="ten_nganh", nullable=false) private String tenNganh;
    @Column(name="ma_nganh", nullable=false) private String maNganh;
    @Column(name="id_khoa", nullable=false) private Long idKhoa;
}