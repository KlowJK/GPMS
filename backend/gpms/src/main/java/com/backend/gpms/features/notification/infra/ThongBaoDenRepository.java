package com.backend.gpms.features.notification.infra;

import com.backend.gpms.features.notification.domain.ThongBaoDen;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ThongBaoDenRepository extends JpaRepository<ThongBaoDen, Long> {
    List<ThongBaoDen> findByUser_Email(String email);
}
