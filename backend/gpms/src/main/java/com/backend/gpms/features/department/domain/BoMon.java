package com.backend.gpms.features.department.domain;
import com.backend.gpms.features.lecturer.domain.GiangVien;
import jakarta.persistence.*;
import lombok.*;

@Getter @Setter
@Entity @Table(name="bo_mon", uniqueConstraints = @UniqueConstraint(name="uq_bo_mon", columnNames={"id_khoa","ten_bo_mon"}))
public class BoMon {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name="ten_bo_mon", nullable=false)
    private String tenBoMon;


    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name="id_truong_bo_mon")
    private GiangVien idTruongBoMon;


    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name="id_khoa", nullable=false)
    private Khoa idKhoa;
}