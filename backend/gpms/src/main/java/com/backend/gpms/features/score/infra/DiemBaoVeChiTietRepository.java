package com.backend.gpms.features.score.infra;

import com.backend.gpms.features.score.domain.DiemBaoVeChiTiet;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DiemBaoVeChiTietRepository extends JpaRepository<DiemBaoVeChiTiet, Long> {
}
