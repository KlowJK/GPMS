package com.backend.gpms.features.lecturer.infra;

import com.backend.gpms.features.lecturer.domain.GiangVien;
import com.backend.gpms.features.lecturer.dto.response.GiangVienLiteProjection;
import com.backend.gpms.features.lecturer.dto.response.GiangVienLiteResponse;
import com.backend.gpms.features.topic.domain.TrangThaiDeTai;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;


import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.Set;

public interface GiangVienRepository extends JpaRepository<GiangVien, Long> {
    Optional<GiangVien> findByUserId(Long userId);

    List<GiangVien> findAllByBoMon_Id(Long boMonId);

    @Override
    List<GiangVien> findAll();

    boolean existsByMaGiangVien(String maGiangVien);

    Optional<GiangVien> findByUser_Email(String taiKhoanEmail);

    Optional<GiangVien> findByMaGiangVien(String maGiangVien);

    Optional<GiangVien> findByUser_EmailIgnoreCase(String email);

    List<GiangVien> findByBoMon_Id(Long boMonId);


    List<GiangVien> findByBoMon_IdOrderByHoTenAsc(Long boMonId);

    @EntityGraph(attributePaths = {"boMon", "user"})
    Page<GiangVien> findAll(Pageable pageable);

    @Query("SELECT gv FROM GiangVien gv " +
            "WHERE gv.boMon.id = :boMonId " +
            "AND (" +
            "   SELECT COUNT(d) FROM DeTai d " +
            "   WHERE d.giangVienHuongDan = gv " +
            "   AND d.sinhVien.user.trangThaiKichHoat = true" +
            ") < 10")
    Set<GiangVien> findAvailableGiangVienByBoMon(@Param("boMonId") Long boMonId);

    @Query("SELECT COUNT(d) FROM DeTai d " +
            "WHERE d.giangVienHuongDan.maGiangVien = :maGV " +
            "AND d.sinhVien.duDieuKien = true")
    int countDeTaiByGiangVienAndSinhVienActive(@Param("maGV") String maGV);

    @Query("""
    select
        gv.id as id,
        concat(
            coalesce(concat(gv.hocHam, ' '), ''),
            coalesce(concat(gv.hocVi, ' '), ''),
            gv.hoTen
        ) as hoTen,
        bm.id as boMonId,
        coalesce(gv.quotaInstruct, 0) as quotaInstruct,
        coalesce(sum(case when d.trangThai = :approved then 1 else 0 end), 0) as currentInstruct,
        (coalesce(gv.quotaInstruct, 0) - coalesce(sum(case when d.trangThai = :approved then 1 else 0 end), 0)) as remaining
    from GiangVien gv
        join gv.boMon bm
        join bm.khoa k
        left join DeTai d on d.giangVienHuongDan = gv
    where k.id = :khoaId
    group by gv.id, gv.hocHam, gv.hocVi, gv.hoTen, bm.id, gv.quotaInstruct
    having (coalesce(gv.quotaInstruct, 0) - coalesce(sum(case when d.trangThai = :approved then 1 else 0 end), 0)) > 0
    order by
        (coalesce(gv.quotaInstruct, 0) - coalesce(sum(case when d.trangThai = :approved then 1 else 0 end), 0)) desc,
        concat(
            coalesce(concat(gv.hocHam, ' '), ''),
            coalesce(concat(gv.hocVi, ' '), ''),
            gv.hoTen
        ) asc
    """)
    List<GiangVienLiteProjection> findAdvisorsWithRemainingByKhoaId(
            @Param("khoaId") Long khoaId,
            @Param("approved") TrangThaiDeTai approved
    );

}