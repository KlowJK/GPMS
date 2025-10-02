package com.backend.gpms.features.department.infra;
import com.backend.gpms.features.department.domain.BoMon;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BoMonRepository extends JpaRepository<BoMon, Long> {
    boolean existsByTenBoMon(String tenBoMon);
}