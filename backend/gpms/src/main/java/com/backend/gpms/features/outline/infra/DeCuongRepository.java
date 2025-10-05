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
            "deTai","deTai.sinhVien","deTai.sinhVien.lop","deTai.giangVienHuongDan","deTai.boMonQuanLy"
    })
    Page<DeCuong> findByDeTai_GiangVienHuongDan_User_EmailIgnoreCaseAndDeTai_DotBaoVe_IdIn(
            String email, List<Long> dotIds, Pageable pageable);

    @EntityGraph(attributePaths = {
            "deTai","deTai.sinhVien","deTai.sinhVien.lop","deTai.giangVienHuongDan","deTai.boMonQuanLy"
    })
    Page<DeCuong> findByDeTai_DotBaoVe_IdIn(List<Long> dotIds, Pageable pageable);

    @EntityGraph(attributePaths = {
            "deTai","deTai.sinhVien","deTai.sinhVien.lop","deTai.giangVienHuongDan","deTai.boMonQuanLy"
    })
    Page<DeCuong> findByTrangThaiDeCuongAndDeTai_BoMon_IdAndDeTai_DotBaoVe_IdIn(
            TrangThaiDeCuong trangThai, Long boMonId, List<Long> dotIds, Pageable pageable);

    @EntityGraph(attributePaths = {
            "deTai","deTai.sinhVien","deTai.sinhVien.lop","deTai.giangVienHuongDan","deTai.boMonQuanLy"
    })
    List<DeCuong> findByTrangThaiDeCuongAndDeTai_BoMon_IdAndDeTai_DotBaoVe_IdIn(
            TrangThaiDeCuong trangThai, Long boMonId, List<Long> dotIds);

    Optional<DeCuong> findByDeTai_SinhVien_User_EmailIgnoreCase(String email);
}