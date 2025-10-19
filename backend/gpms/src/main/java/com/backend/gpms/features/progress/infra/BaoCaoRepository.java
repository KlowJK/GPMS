package com.backend.gpms.features.progress.infra;

import com.backend.gpms.features.outline.domain.TrangThaiDuyetDon;
import com.backend.gpms.features.progress.domain.BaoCao;
import org.apache.poi.sl.draw.geom.GuideIf;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface BaoCaoRepository extends JpaRepository<BaoCao, Long> {
    Optional<BaoCao> findById(Long id);
    List<BaoCao> findByDeTai_SinhVien_User_EmailOrderByCreatedAt(String email);
    List<BaoCao> findByDeTai_GiangVienHuongDan_User_EmailIgnoreCase(String email);

    List<BaoCao> findByGiangVienHuongDan_IdOrderByCreatedAt(Long giangVienId);

    List<BaoCao> findByGiangVienHuongDan_IdAndTrangThaiOrderByCreatedAt(Long giangVienId, TrangThaiDuyetDon trangThaiBaoCao);

    Page<BaoCao> findByGiangVienHuongDan_Id(Long giangVienId, Pageable pageable);

    Page<BaoCao> findByGiangVienHuongDan_IdAndTrangThai(Long giangVienId, TrangThaiDuyetDon trangThaiBaoCao, Pageable pageable);

    Page<BaoCao> findByDeTai_GiangVienHuongDan_IdOrderByCreatedAtDesc(Long giangVienId, Pageable pageable);

    Optional<BaoCao> findFirstByDeTai_SinhVien_User_EmailIgnoreCase(String email);

    @Query("SELECT b FROM BaoCao b WHERE b.deTai.giangVienHuongDan.id = :giangVienId AND b.createdAt >= :startOfToday ORDER BY b.createdAt DESC")
    List<BaoCao> findTodayReportsByGiangVienHuongDanId(Long giangVienId, LocalDateTime startOfToday);

    Optional<BaoCao> findFirstByDeTai_IdOrderByCreatedAtDesc(Long deTaiId);

    List<BaoCao> findByDeTai_IdOrderByCreatedAtDesc(Long deTaiId);

}
