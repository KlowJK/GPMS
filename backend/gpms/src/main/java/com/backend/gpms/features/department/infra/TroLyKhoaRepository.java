package com.backend.gpms.features.department.infra;

import com.backend.gpms.features.department.domain.TroLyKhoa;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface TroLyKhoaRepository extends JpaRepository<TroLyKhoa, Long> {

    Optional<TroLyKhoa> findById(Long id);

    List<TroLyKhoa> findAll();

    Optional<TroLyKhoa> findByUser_Id(Long userId);

    boolean existsByUser_Id(Long userId);
}
