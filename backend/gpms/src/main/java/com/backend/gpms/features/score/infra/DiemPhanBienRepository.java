package com.backend.gpms.features.score.infra;

import com.backend.gpms.features.score.domain.DiemPhanBien;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DiemPhanBienRepository extends JpaRepository<DiemPhanBien, Long> {
}
