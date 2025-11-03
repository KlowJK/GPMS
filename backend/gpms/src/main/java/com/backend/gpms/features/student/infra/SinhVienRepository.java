// StudentRepository.java
package com.backend.gpms.features.student.infra;

import com.backend.gpms.features.defense.domain.DotBaoVe;
import com.backend.gpms.features.student.domain.SinhVien;
import com.backend.gpms.features.topic.domain.TrangThaiDeTai;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface SinhVienRepository extends JpaRepository<SinhVien, Long>, JpaSpecificationExecutor<SinhVien> {
    Optional<SinhVien> findByUserId(Long userId);

    Optional<SinhVien> findByUser_Email(String email);
    Optional<SinhVien> findByMaSinhVien(String maSinhVien);


    Optional<SinhVien> findByUser_EmailIgnoreCase(String email);
    boolean existsByUser_Email(String email);
    boolean existsByMaSinhVien(String maSV);
    Page<SinhVien> findByDeTai_GiangVienHuongDan_IdAndDeTai_DotBaoVe(Long gvhdId, DotBaoVe dotBaoVe, Pageable pageable);
    Page<SinhVien> findByDeTai_GiangVienHuongDan_IdAndDeTai_TrangThaiAndDeTai_DotBaoVe(Long gvhdId, TrangThaiDeTai trangThai, DotBaoVe dotBaoVe, Pageable pageable);

    Page<SinhVien> findAllByHoTenContainingIgnoreCaseOrMaSinhVienContainingIgnoreCase(String hoTen, String maSV, Pageable pageable);

    List<SinhVien> findByDeTai_GiangVienHuongDan_IdAndDeTai_DotBaoVeAndDeTai_TrangThaiOrderByHoTenDesc(Long deTaiGiangVienHuongDanId, DotBaoVe deTaiDotBaoVe, TrangThaiDeTai deTaiTrangThai);


    List<SinhVien> findAllByDeTaiIsNullAndUser_TrangThaiKichHoatTrue();

    // MỚI: KHÔNG phân trang - trả về tất cả, sắp xếp theo họ tên
    List<SinhVien> findByDeTai_GiangVienHuongDan_IdAndDeTai_DotBaoVeOrderByHoTenAsc(
            Long gvhdId, DotBaoVe dotBaoVe
    );

    // MỚI: KHÔNG phân trang + tìm kiếm theo q
    @Query("""
        SELECT sv FROM SinhVien sv
        JOIN sv.deTai dt
        LEFT JOIN sv.lop l
        WHERE dt.giangVienHuongDan.id = :gvhdId
          AND dt.dotBaoVe = :dotBaoVe
          AND (
               LOWER(sv.hoTen)      LIKE LOWER(CONCAT('%', :q, '%'))
            OR LOWER(sv.maSinhVien)       LIKE LOWER(CONCAT('%', :q, '%'))
            OR LOWER(COALESCE(sv.soDienThoai, '')) LIKE LOWER(CONCAT('%', :q, '%'))
            OR LOWER(COALESCE(l.tenLop, ''))      LIKE LOWER(CONCAT('%', :q, '%'))
            OR LOWER(COALESCE(dt.tenDeTai, ''))   LIKE LOWER(CONCAT('%', :q, '%'))
          )
        ORDER BY sv.hoTen ASC
        """)
    List<SinhVien> searchMySupervisedAll(
            @Param("gvhdId") Long gvhdId,
            @Param("dotBaoVe") DotBaoVe dotBaoVe,
            @Param("q") String q
    );

    Page<SinhVien> findByDeTai_BoMon_IdAndDeTai_DotBaoVe(Long boMonId, DotBaoVe dotBaoVe, Pageable pageable);
    Page<SinhVien> findByDeTai_BoMon_IdAndDeTai_TrangThaiAndDeTai_DotBaoVe(Long boMonId, TrangThaiDeTai trangThai, DotBaoVe dotBaoVe, Pageable pageable);

    @Query("""
    SELECT DISTINCT sv FROM SinhVien sv
    JOIN sv.lop l
    JOIN l.nganh n
    LEFT JOIN sv.deTai dt
    WHERE n.boMon.id = :idBoMon
      AND (dt.dotBaoVe = :dotBaoVe OR dt.id IS NULL)
      AND (
        :status IS NULL
        OR (:status = 'TU_CHOI' AND (dt.trangThai = :status OR dt.id IS NULL))
        OR (:status != 'TU_CHOI' AND dt.trangThai = :status)
      )
    """)
    Page<SinhVien> findSinhVienForBoMonApproval(
            @Param("idBoMon") Long idBoMon,
            @Param("dotBaoVe") DotBaoVe dotBaoVe,
            @Param("status") TrangThaiDeTai status,
            Pageable pageable
    );

}
