package com.backend.gpms.features.topic.infra;

import com.backend.gpms.features.department.domain.Khoa;
import com.backend.gpms.features.topic.domain.DonHoanDoAn;
import com.backend.gpms.features.topic.domain.TrangThaiDeTai;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DonHoanDoAnRepository extends JpaRepository<DonHoanDoAn, Long> {
    boolean existsBySinhVien_IdAndTrangThai(Long sinhVienId, TrangThaiDeTai trangThai);
    Page<DonHoanDoAn> findBySinhVien_Id(Long sinhVienId, Pageable pageable);

    Page<DonHoanDoAn> findBySinhVien_Lop_Nganh_Khoa(Khoa khoa, Pageable pageable);
}