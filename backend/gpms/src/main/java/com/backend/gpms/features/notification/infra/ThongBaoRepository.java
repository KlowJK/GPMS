package com.backend.gpms.features.notification.infra;
import com.backend.gpms.features.notification.domain.LoaiThongBao;
import com.backend.gpms.features.notification.domain.ThongBao;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ThongBaoRepository extends JpaRepository<ThongBao, Long> {
    List<ThongBao> findByLoaiThongBaoOrderByCreatedAtDesc(LoaiThongBao loaiThongBao);
    List<ThongBao> findByThongBaoDens_User_IdOrderByCreatedAtDesc(Long id);
    List<ThongBao> findAll();

    Page<ThongBao> findByLoaiThongBaoIn(List<LoaiThongBao> loaiThongBaos, Pageable pageable);}
