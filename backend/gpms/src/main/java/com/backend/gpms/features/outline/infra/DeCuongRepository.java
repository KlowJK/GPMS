package com.backend.gpms.features.outline.infra;

import com.backend.gpms.features.outline.domain.DeCuong;
import com.backend.gpms.features.outline.domain.TrangThaiDeCuong;
import com.backend.gpms.features.outline.domain.TrangThaiDuyetDon;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface DeCuongRepository extends JpaRepository<DeCuong,Long> {
    Optional<DeCuong> findDeCuongById(Long id);

    @Override
    @EntityGraph(attributePaths = { "deTai", "deTai.sinhVien", "deTai.giangVienHuongDan" })
    Page<DeCuong> findAll(Pageable pageable);

    @EntityGraph(attributePaths = {
            "deTai","deTai.sinhVien","deTai.sinhVien.lop","deTai.giangVienHuongDan","deTai.boMon"
    })
    Page<DeCuong> findByDeTai_GiangVienHuongDan_User_EmailIgnoreCaseAndDeTai_DotBaoVe_IdIn(
            String email, List<Long> dotIds, Pageable pageable);

    @EntityGraph(attributePaths = {
            "deTai","deTai.sinhVien","deTai.sinhVien.lop","deTai.giangVienHuongDan","deTai.boMon"
    })
    Page<DeCuong> findByDeTai_DotBaoVe_IdIn(List<Long> dotIds, Pageable pageable);

    @EntityGraph(attributePaths = {
            "deTai","deTai.sinhVien","deTai.sinhVien.lop","deTai.giangVienHuongDan","deTai.boMon"
    })
    Page<DeCuong> findByTrangThaiDeCuongAndDeTai_BoMon_IdAndDeTai_DotBaoVe_IdIn(
            TrangThaiDeCuong trangThai, Long boMonId, List<Long> dotIds, Pageable pageable);

    @EntityGraph(attributePaths = {
            "deTai","deTai.sinhVien","deTai.sinhVien.lop","deTai.giangVienHuongDan","deTai.boMon"
    })
    List<DeCuong> findByTrangThaiDeCuongAndDeTai_BoMon_IdAndDeTai_DotBaoVe_IdIn(
            TrangThaiDeCuong trangThai, Long boMonId, List<Long> dotIds);

    Optional<DeCuong> findFirstByDeTai_SinhVien_User_EmailIgnoreCaseOrderByCreatedAtDesc(String email);

    List<DeCuong> findByDeTai_SinhVien_User_EmailIgnoreCase(String email);

    Page<DeCuong> findByTruongBoMon_User_Email(String email, Pageable pageable);
    Page<DeCuong> findByGiangVienPhanBien_User_Email(String email, Pageable pageable);
    Page<DeCuong> findByGiangVienHuongDan_User_EmailIgnoreCaseOrGiangVienPhanBien_User_EmailIgnoreCaseOrTruongBoMon_User_EmailIgnoreCaseAndDeTai_DotBaoVe_IdInAndTrangThaiDeCuongOrderByCreatedAtDesc(
            String email1, String email2, String email3, List<Long> dotIds, TrangThaiDeCuong trangThaiDeCuong, Pageable pageable
    );
    Page<DeCuong> findByGiangVienHuongDan_User_EmailIgnoreCaseOrGiangVienPhanBien_User_EmailIgnoreCaseOrTruongBoMon_User_EmailIgnoreCaseAndDeTai_DotBaoVe_IdInOrderByCreatedAtDesc(
            String email1, String email2, String email3, List<Long> dotIds, Pageable pageable
    );

    @Query("SELECT d FROM DeCuong d WHERE " +
           "(LOWER(d.giangVienHuongDan.user.email) = LOWER(:email1) " +
           "OR LOWER(d.giangVienPhanBien.user.email) = LOWER(:email2) " +
           "OR LOWER(d.truongBoMon.user.email) = LOWER(:email3)) " +
           "AND d.deTai.dotBaoVe.id IN :dotIds " +
           "AND (d.trangThaiDeCuong = :trangThaiDeCuong " +
           "OR d.gvPhanBienDuyet = :gvPhanBienDuyet " +
           "OR d.tbmDuyet = :tbmDuyet) " +
           "ORDER BY d.createdAt DESC")
    Page<DeCuong> findOutlineWithAnyStatus(
        @Param("email1") String email1,
        @Param("email2") String email2,
        @Param("email3") String email3,
        @Param("dotIds") List<Long> dotIds,
        @Param("trangThaiDeCuong") TrangThaiDeCuong trangThaiDeCuong,
        @Param("gvPhanBienDuyet") TrangThaiDuyetDon gvPhanBienDuyet,
        @Param("tbmDuyet") TrangThaiDuyetDon tbmDuyet,
        Pageable pageable
    );

    List<DeCuong> findByDeTai_SinhVien_MaSinhVien(String maSinhVien);

    Optional<DeCuong> findFirstByDeTai_IdOrderByUpdatedAtDesc(Long ids);
}