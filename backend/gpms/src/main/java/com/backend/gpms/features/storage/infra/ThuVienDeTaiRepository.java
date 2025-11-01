package com.backend.gpms.features.storage.infra;

import com.backend.gpms.features.storage.domain.ThuVienDeTai;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ThuVienDeTaiRepository  extends JpaRepository<ThuVienDeTai,Long> {
}