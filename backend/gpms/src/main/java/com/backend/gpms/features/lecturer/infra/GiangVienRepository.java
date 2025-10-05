package com.backend.gpms.features.lecturer.infra;

import com.backend.gpms.features.lecturer.domain.GiangVien;
import org.apache.poi.sl.draw.geom.GuideIf;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface GiangVienRepository extends JpaRepository<GiangVien, Long> {
    Optional<GiangVien> findByUserId(Long userId) ;

    List<GiangVien> findAllByBoMon_Id(Long boMonId);

    @Override
    List<GiangVien> findAll();
    boolean existsByMaGiangVien(String maGiangVien);
    Optional<GiangVien> findByUser_Email(String taiKhoanEmail);
    Optional<GiangVien> findByMaGiangVien(String maGiangVien);

    Optional<GiangVien> findByUser_EmailIgnoreCase(String email);
    List<GiangVien> findByBoMon_Id(Long boMonId);

