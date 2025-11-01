package com.backend.gpms.features.score.infra;

import com.backend.gpms.features.score.domain.Diem;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;


public interface DiemRepository extends JpaRepository<Diem,Long> {
    Optional<Diem> findByDeTai_Id(Long deTaiId);
}