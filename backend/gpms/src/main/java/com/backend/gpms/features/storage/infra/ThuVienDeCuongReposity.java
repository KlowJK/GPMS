package com.backend.gpms.features.storage.infra;

import com.backend.gpms.features.storage.domain.ThuVienDeCuong;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ThuVienDeCuongReposity extends JpaRepository<ThuVienDeCuong,Long> {
}
