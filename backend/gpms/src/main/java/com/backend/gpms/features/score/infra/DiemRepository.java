package com.backend.gpms.features.score.infra;

import com.backend.gpms.features.score.domain.Diem;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DiemRepository extends JpaRepository<Diem,Long> {
}