package com.backend.gpms.features.auth.infra;

import com.backend.gpms.features.auth.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);

    @Query("SELECT DISTINCT u FROM User u " +
            "WHERE u IN (" +
            "   SELECT sv.user FROM Khoa k " +
            "   JOIN k.nganhSet n " +
            "   JOIN n.lopSet l " +
            "   JOIN l.sinhVienSet sv " +
            "   WHERE k.id = :khoaId " +
            ") OR u IN (" +
            "   SELECT gv.user FROM Khoa k " +
            "   JOIN k.boMonSet bm " +
            "   JOIN bm.giangVienSet gv " +
            "   WHERE k.id = :khoaId " +
            ")")
    List<User> findAllTaiKhoanSinhVienAndGiangVienByKhoaId(@Param("khoaId") Long khoaId);

    @Query("SELECT DISTINCT sv.user " +
            "FROM Khoa k " +
            "JOIN k.nganhSet n " +
            "JOIN n.lopSet l " +
            "JOIN l.sinhVienSet sv " +
            "JOIN sv.user tk " +
            "WHERE LOWER(k.tenKhoa) = LOWER(:tenKhoa)")
    List<User> findAllTaiKhoanByTenKhoaIgnoreCase(@Param("tenKhoa") String tenKhoa);
}