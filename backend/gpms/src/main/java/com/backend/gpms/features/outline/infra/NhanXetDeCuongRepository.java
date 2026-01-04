package com.backend.gpms.features.outline.infra;



import com.backend.gpms.features.outline.domain.NhanXetDeCuong;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;

public interface NhanXetDeCuongRepository extends JpaRepository<NhanXetDeCuong,Long> {
    List<NhanXetDeCuong> findByDeCuong_IdOrderByCreatedAtAsc(Long deCuongId);

    List<NhanXetDeCuong> findByDeCuong_IdInOrderByCreatedAtDesc(Collection<Long> deCuongIds);
}

