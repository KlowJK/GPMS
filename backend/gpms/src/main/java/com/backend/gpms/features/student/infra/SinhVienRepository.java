// StudentRepository.java
package com.backend.gpms.features.student.infra;

import com.backend.gpms.features.student.domain.SinhVien;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface SinhVienRepository extends JpaRepository<SinhVien, Long> {
    Optional<SinhVien> findByUserId(Long userId);

    Optional<SinhVien> findByUser_Email(String email);
    Optional<SinhVien> findByMaSinhVien(String maSinhVien);
}
