package com.backend.gpms.features.council.infra;

import com.backend.gpms.features.council.domain.HoiDong;
import com.backend.gpms.features.defense.domain.DotBaoVe;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface HoiDongRepository extends JpaRepository<HoiDong, Long> {
    Page<HoiDong> findByTenHoiDongContainingIgnoreCaseAndThoiGianBatDauLessThanEqualAndThoiGianKetThucGreaterThanEqual(String keyword, LocalDate to1, LocalDate to2, Pageable pageable);

    Page<HoiDong> findByThoiGianBatDauLessThanEqualAndThoiGianKetThucGreaterThanEqual(LocalDate to1, LocalDate to2, Pageable pageable);

    Page<HoiDong> findByDotBaoVe_Id(Long dotBaoVeId, Pageable pageable);

    Page<HoiDong> findByDotBaoVe_IdAndTenHoiDongContainingIgnoreCase(Long dotBaoVeId, String keyword, Pageable pageable);

    boolean existsByDotBaoVe_IdAndDeTaiSet_IdAndIdNot(
            Long dotBaoVeId, Long deTaiId, Long excludeHoiDongBaoVeId
    );

    Optional<HoiDong> findFirstByDotBaoVe_IdAndDeTaiSet_IdAndIdNot(
            Long dotBaoVeId, Long deTaiId, Long excludeHoiDongBaoVeId
    );

    boolean existsByDeTaiSet_Id(Long deTaiId);

    boolean existsByDeTaiSet_IdAndIdNot(Long deTaiId, Long HoiDongBaoVeId);

    @Query("""
        select distinct hd from HoiDong hd
        left join fetch hd.thanhVienHoiDongSet tv
        left join fetch tv.giangVien gv
        left join fetch hd.deTaiSet dt
        left join fetch dt.sinhVien sv
        left join fetch sv.lop l
        left join fetch dt.giangVienHuongDan gvhd
        left join fetch gvhd.boMon bm
        where hd.id = :id
""")Optional<HoiDong> fetchDetail(@Param("id") Long id);

    Page<HoiDong> findHoiDongByDotBaoVeAndTenHoiDongContainingIgnoreCase(DotBaoVe dotBaoVe, String tenHoiDongBaoVe, Pageable pageable);

    List<HoiDong> findHoiDongByDotBaoVeAndTenHoiDongContainingIgnoreCase(DotBaoVe dotBaoVe, String tenHoiDongBaoVe);

    Page<HoiDong> findHoiDongByDotBaoVe(DotBaoVe dotBaoVe, Pageable pageable);

    List<HoiDong> findHoiDongByDotBaoVe(DotBaoVe dotBaoVe);

    Page<HoiDong> findByDotBaoVeAndDeTaiSet_Id(DotBaoVe dotBaoVe, Long deTaiId, Pageable pageable);

    List<HoiDong> findByDotBaoVeAndDeTaiSet_Id(DotBaoVe dotBaoVe, Long deTaiId);

    Page<HoiDong>findByDotBaoVeAndThanhVienHoiDongSet_GiangVien_Id(DotBaoVe dotBaoVe,Long giangVienId, Pageable pageable);

    List<HoiDong> findByDotBaoVeAndThanhVienHoiDongSet_GiangVien_Id(DotBaoVe dotBaoVe,Long giangVienId);
}
