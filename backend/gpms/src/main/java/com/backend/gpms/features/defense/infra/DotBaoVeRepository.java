package com.backend.gpms.features.defense.infra;

import com.backend.gpms.features.defense.domain.DotBaoVe;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

import java.time.LocalDate;
import java.util.Optional;

public interface DotBaoVeRepository extends JpaRepository<DotBaoVe, Long> {

    boolean existsByTenDotBaoVe(String tenDotBaoVe);

    boolean existsByTenDotBaoVeAndIdNot(String tenDotBaoVe, Long id);

    Optional<DotBaoVe> findByHocKiAndNamBatDauAndNamKetThuc(int hocKi, int namBatDau, int namKetThuc);

    Optional<DotBaoVe>
    findTopByThoiGianBatDauLessThanEqualAndThoiGianKetThucGreaterThanEqualOrderByThoiGianBatDauDesc(
            LocalDate today1, LocalDate today2
    );
}
