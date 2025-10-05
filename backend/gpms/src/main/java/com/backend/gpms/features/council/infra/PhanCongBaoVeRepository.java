package com.backend.gpms.features.council.infra;

import com.backend.gpms.features.council.domain.PhanCongBaoVe;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PhanCongBaoVeRepository extends JpaRepository<PhanCongBaoVe, Long> {
}
