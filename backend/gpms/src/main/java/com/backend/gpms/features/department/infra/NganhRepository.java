package com.backend.gpms.features.department.infra;

import com.backend.gpms.features.department.domain.Nganh;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface NganhRepository extends JpaRepository<Nganh,Long> {
    Optional<Nganh> findById(Long id);
    boolean existsByTenNganh(String tenNganh);
}
