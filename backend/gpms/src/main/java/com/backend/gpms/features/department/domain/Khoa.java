package com.backend.gpms.features.department.domain;
import jakarta.persistence.*;
import lombok.*;

@Getter @Setter
@Entity @Table(name="khoa")
public class Khoa {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(name="ten_khoa", nullable=false, unique=true)
    private String tenKhoa;
}