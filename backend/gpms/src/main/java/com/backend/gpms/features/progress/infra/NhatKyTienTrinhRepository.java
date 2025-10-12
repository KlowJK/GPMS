package com.backend.gpms.features.progress.infra;

import com.backend.gpms.features.progress.domain.NhatKyTienTrinh;
import com.backend.gpms.features.topic.domain.TrangThaiDeTai;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface NhatKyTienTrinhRepository extends JpaRepository<NhatKyTienTrinh, Long> {
    Optional<NhatKyTienTrinh> findById(Long aLong);

    List<NhatKyTienTrinh> findByDeTai_Id(Long aLong);

    List<NhatKyTienTrinh> findByGiangVienHuongDan_IdOrderByCreatedAt(Long aLong);

    Page<NhatKyTienTrinh> findByGiangVienHuongDan_IdAndTrangThaiNhatKyOrderByCreatedAt(Long aLong, TrangThaiDeTai trangThaiNhatKy, Pageable pageable);
    Page<NhatKyTienTrinh> findByGiangVienHuongDan_IdOrderByCreatedAt(Long aLong, Pageable pageable);

    List<NhatKyTienTrinh> findByDeTai_IdOrderByCreatedAtDesc(Long deTaiId);

    Page<NhatKyTienTrinh> findByDeTai_IdOrderByCreatedAt(Long deTaiId, Pageable pageable);

}
