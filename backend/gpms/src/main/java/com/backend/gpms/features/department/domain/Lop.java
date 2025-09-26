package com.backend.gpms.features.department.domain;
import jakarta.persistence.*;
import lombok.*;

@Getter @Setter
@Entity @Table(name="lop", uniqueConstraints = @UniqueConstraint(name="uq_lop", columnNames={"id_nganh","ten_lop"}))
public class Lop {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    @Column(name="ten_lop", nullable=false) private String tenLop;
    @Column(name="id_nganh", nullable=false) private Long idNganh;
}