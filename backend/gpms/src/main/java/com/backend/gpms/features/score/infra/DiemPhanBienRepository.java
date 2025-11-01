package com.backend.gpms.features.score.infra;

import com.backend.gpms.features.score.domain.DiemPhanBien;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface DiemPhanBienRepository extends JpaRepository<DiemPhanBien, Long> {
    List<DiemPhanBien> findByPhanCongPhanBien_DeTai_Id(Long deTaiId);

    Optional<DiemPhanBien> findByPhanCongPhanBien_Id(Long phanCongPhanBienId);


}
