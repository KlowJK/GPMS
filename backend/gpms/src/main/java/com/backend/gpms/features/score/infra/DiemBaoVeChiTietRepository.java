package com.backend.gpms.features.score.infra;

import com.backend.gpms.features.score.domain.DiemBaoVeChiTiet;
import org.apache.poi.sl.draw.geom.GuideIf;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface DiemBaoVeChiTietRepository extends JpaRepository<DiemBaoVeChiTiet, Long> {
    List<DiemBaoVeChiTiet> findByDeTai_IdAndHopLeTrue(Long deTaiId);

    Optional<DiemBaoVeChiTiet> findByDeTai_IdAndThanhVienHoiDong_GiangVien_Id(Long deTaiId, Long giangVienId);

    List<DiemBaoVeChiTiet> findByDeTai_Id(Long deTaiId);

    Optional<DiemBaoVeChiTiet> findByDeTai_IdAndThanhVienHoiDong_Id(Long deTaiId, Long thanhVienHoiDongId);
}
