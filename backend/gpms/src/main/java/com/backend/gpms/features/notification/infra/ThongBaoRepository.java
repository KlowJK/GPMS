package com.backend.gpms.features.notification.infra;
import com.backend.gpms.features.notification.domain.LoaiThongBao;
import com.backend.gpms.features.notification.domain.ThongBao;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ThongBaoRepository extends JpaRepository<ThongBao, Long> {
    List<ThongBao> findByLoaiThongBaoOrderByCreatedAtDesc(LoaiThongBao loaiThongBao);
    List<ThongBao> findByThongBaoDens_User_IdOrderByCreatedAtDesc(Long id);

}
