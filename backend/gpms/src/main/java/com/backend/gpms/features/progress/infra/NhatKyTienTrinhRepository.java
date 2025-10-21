package com.backend.gpms.features.progress.infra;

import com.backend.gpms.features.progress.domain.NhatKyTienTrinh;
import com.backend.gpms.features.progress.domain.TrangThaiNhatKy;
import com.backend.gpms.features.topic.domain.TrangThaiDeTai;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface NhatKyTienTrinhRepository extends JpaRepository<NhatKyTienTrinh, Long> {
    Optional<NhatKyTienTrinh> findById(Long aLong);

    List<NhatKyTienTrinh> findByDeTai_IdOrderByCreatedAt(Long aLong);

    List<NhatKyTienTrinh> findByDeTai_IdAndTuanOrderByCreatedAt(Long id,int tuan);

    List<NhatKyTienTrinh> findByGiangVienHuongDan_IdOrderByCreatedAt(Long aLong);

    Page<NhatKyTienTrinh> findByGiangVienHuongDan_IdAndTrangThaiNhatKyOrderByCreatedAt(Long aLong, TrangThaiNhatKy trangThaiNhatKy, Pageable pageable);
    List<NhatKyTienTrinh> findByGiangVienHuongDan_IdAndTrangThaiNhatKyOrderByCreatedAt(Long aLong, TrangThaiNhatKy trangThaiNhatKy);
    Page<NhatKyTienTrinh> findByGiangVienHuongDan_IdOrderByCreatedAt(Long aLong, Pageable pageable);

    @Query("SELECT n FROM NhatKyTienTrinh n WHERE n.deTai.id = :deTaiId AND n.ngayBatDau <= :currentDate ORDER BY n.tuan DESC")
    List<NhatKyTienTrinh> findByDeTai_IdAndNgayBatDauBeforeOrderByTuanDesc(Long deTaiId, LocalDateTime currentDate);
    List<NhatKyTienTrinh> findByDeTai_IdOrderByTuanDesc(Long deTaiId);

    Page<NhatKyTienTrinh> findByDeTai_IdOrderByCreatedAt(Long deTaiId, Pageable pageable);

    Page<NhatKyTienTrinh> findByDeTai_IdAndTuanOrderByCreatedAt(Long id,int tuan, Pageable pageable);

    Optional<NhatKyTienTrinh> findByDeTai_IdAndTuan(Long deTaiId, int tuan);


    Page<NhatKyTienTrinh> findByDeTai_IdAndNgayBatDauBetween(Long deTaiId, LocalDateTime start, LocalDateTime end, Pageable pageable);

}
