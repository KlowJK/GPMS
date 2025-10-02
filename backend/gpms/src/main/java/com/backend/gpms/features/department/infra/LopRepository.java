package com.backend.gpms.features.department.infra;


import com.backend.gpms.features.department.domain.Lop;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface LopRepository extends JpaRepository<Lop, Long> {
    @Override
    Optional<Lop> findById(Long aLong);
    boolean existsByTenLop(String tenLop);
}
