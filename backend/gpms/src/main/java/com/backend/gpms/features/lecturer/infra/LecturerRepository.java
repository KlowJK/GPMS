package com.backend.gpms.features.lecturer.infra;

import org.springframework.data.jpa.repository.JpaRepository;
import com.backend.gpms.features.lecturer.domain.Lecturer;

import java.util.Optional;

public interface LecturerRepository extends JpaRepository<Lecturer, Long> {
Optional<Lecturer>  findByMaGiangVien(String maGiangVien);
}
