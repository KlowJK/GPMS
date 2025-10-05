package com.backend.gpms.features.department.infra;
import com.backend.gpms.features.department.domain.BoMon;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface BoMonRepository extends JpaRepository<BoMon, Long> {
    boolean existsByTenBoMon(String tenBoMon);
    boolean existsByTenBoMonIgnoreCase(String tenBoMon);
    Optional<BoMon> findByTenBoMon(String tenBoMon);
}