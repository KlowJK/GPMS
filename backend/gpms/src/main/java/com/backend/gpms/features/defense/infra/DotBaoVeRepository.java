package com.backend.gpms.features.defense.infra;

import com.backend.gpms.features.defense.domain.DotBaoVe;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

import java.time.LocalDate;
import java.util.Optional;

public interface DotBaoVeRepository extends JpaRepository<DotBaoVe, Long> {

    boolean existsByTenDot(String tenDotBaoVe);

    boolean existsByTenDotAndIdNot(String tenDotBaoVe, Long id);

    Optional<DotBaoVe> findByHocKiAndNamHoc(String hocKi, String namHoc);

    Optional<DotBaoVe>
    findTopByNgayBatDauLessThanEqualAndNgayKetThucGreaterThanEqualOrderByNgayBatDauDesc(
            LocalDate today1, LocalDate today2
    );
}
