package com.backend.gpms.features.storage.infra;

import com.backend.gpms.features.storage.domain.ThuVienDeTai;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ThuVienDeTaiRepository  extends JpaRepository<ThuVienDeTai,Long> {

    Optional<ThuVienDeTai> findByDeTaiAndDotBaoVe_Id(String deTai, Long dotBaoVeId);
    List<ThuVienDeTai> findAllByOrderByIdDesc();
}