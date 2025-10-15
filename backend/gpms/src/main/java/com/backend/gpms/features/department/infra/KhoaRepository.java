package com.backend.gpms.features.department.infra;
import com.backend.gpms.features.department.domain.Khoa;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;


public interface KhoaRepository extends JpaRepository<Khoa,Long> {

    boolean existsByTenKhoaIgnoreCase(String tenKhoa);

    List<Khoa> findAllByOrderByTenKhoaAsc();


}
