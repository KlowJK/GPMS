package com.backend.gpms.features.outline.infra;

import com.backend.gpms.features.outline.domain.DeCuong;
import com.backend.gpms.features.outline.domain.TrangThaiDeCuong;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

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
    Page<DeCuong> findByGiangVienHuongDan_User_EmailIgnoreCaseOrGiangVienPhanBien_User_EmailIgnoreCaseOrTruongBoMon_User_EmailIgnoreCaseAndDeTai_DotBaoVe_IdIn(
            String email1, String email2, String email3, List<Long> dotIds, Pageable pageable
    );
}