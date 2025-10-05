package com.backend.gpms.features.defense.infra;

import com.backend.gpms.features.defense.domain.CongViec;
import com.backend.gpms.features.defense.domain.DotBaoVe;
import com.backend.gpms.features.defense.domain.ThoiGianThucHien;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface ThoiGianThucHienRepository extends JpaRepository<ThoiGianThucHien, Long> {

    @EntityGraph(attributePaths = {"dotBaoVe"})
    List<ThoiGianThucHien> findAllByCongViecAndThoiGianBatDauLessThanEqualAndThoiGianKetThucGreaterThanEqual(
            CongViec congViec, LocalDate today1, LocalDate today2
    );

    boolean existsByDotBaoVeAndCongViec(DotBaoVe dotBaoVe, CongViec congViec);
    Optional<ThoiGianThucHien> findByDotBaoVeAndCongViec(DotBaoVe dotBaoVe, CongViec congViec);
    Optional<ThoiGianThucHien> findByDotBaoVe_IdAndCongViec(Long dotBaoVeId, CongViec congViec);

    Optional<ThoiGianThucHien> findTopByCongViecAndThoiGianBatDauLessThanEqualAndThoiGianKetThucGreaterThanEqualOrderByThoiGianBatDauDesc(
            CongViec cv, LocalDate today1, LocalDate today2
    );
}