package com.backend.gpms.features.council.infra;

import com.backend.gpms.features.council.domain.ThanhVienHoiDong;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ThanhVienHoiDongRepository extends JpaRepository<ThanhVienHoiDong, Long> {
    List<ThanhVienHoiDong> findByHoiDong_Id(Long hoiDongId);
    Optional<ThanhVienHoiDong> findByGiangVien_Id(Long giangVienId);
}