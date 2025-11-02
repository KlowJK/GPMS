package com.backend.gpms.features.storage.infra;

import com.backend.gpms.features.storage.domain.ThuVienDeCuong;
import com.backend.gpms.features.storage.domain.ThuVienDeTai;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ThuVienDeCuongRepository extends JpaRepository<ThuVienDeCuong,Long> {
    boolean existsByThuVienDeTaiAndPhienBan(ThuVienDeTai thuVienDeTai, String phienBan);
    List<ThuVienDeCuong> findByThuVienDeTai(ThuVienDeTai thuVienDeTai);
}
