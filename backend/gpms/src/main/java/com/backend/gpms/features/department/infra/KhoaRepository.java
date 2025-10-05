package com.backend.gpms.features.department.infra;
import com.backend.gpms.features.department.domain.Khoa;
import org.springframework.data.jpa.repository.JpaRepository;



public interface KhoaRepository extends JpaRepository<Khoa,Long> {

    boolean existsByTenKhoaIgnoreCase(String tenKhoa);

}
