package com.backend.gpms.features.lecturer.infra;
import com.backend.gpms.features.auth.domain.User;
import com.backend.gpms.features.lecturer.domain.GiangVien;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface GiangVienRepository extends JpaRepository<GiangVien, Long> {
    Optional<GiangVien> findByUserId(Long userId) ;


}
