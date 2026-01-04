package com.backend.gpms.features.council.infra;

import com.backend.gpms.features.council.domain.PhanCongBaoVe;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface PhanCongBaoVeRepository extends JpaRepository<PhanCongBaoVe, Long> {
    Optional<PhanCongBaoVe> findByDeTai_Id(Long deTaiId);
}
