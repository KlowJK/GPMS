package com.backend.gpms.features.council.infra;

import com.backend.gpms.features.council.domain.PhanCongPhanBien;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface PhanCongPhanBienRepository extends JpaRepository<PhanCongPhanBien, Long> {
    List<PhanCongPhanBien> findByDeTai_Id(Long idDeTai);

    int countByDeTai_Id(Long deTaiId);

    Optional<PhanCongPhanBien> findByDeTai_IdAndGiangVien_Id(Long deTaiId, Long giangVienId);

    boolean existsByDeTai_IdAndGiangVien_Id(Long deTaiId, Long giangVienId);
}
