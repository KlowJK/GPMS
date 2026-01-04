package com.backend.gpms.features.account.infra;

import com.backend.gpms.features.account.domain.QuanTriVien;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface QuanTriVienRepository extends JpaRepository<QuanTriVien, Long> {
    Optional<QuanTriVien> findByUserId(Long userId);
}

