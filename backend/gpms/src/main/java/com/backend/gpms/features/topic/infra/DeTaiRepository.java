package  com.backend.gpms.features.topic.infra;

import com.backend.gpms.features.lecturer.infra.GiangVienLoad;
import com.backend.gpms.features.progress.domain.NhatKyTienTrinh;
import com.backend.gpms.features.student.domain.SinhVien;
import com.backend.gpms.features.topic.domain.DeTai;
import com.backend.gpms.features.topic.domain.TrangThaiDeTai;
import org.springframework.data.domain.Example;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

public interface DeTaiRepository extends JpaRepository<DeTai, Long> {
    Optional<DeTai> findById(Long id);

    @Query("""
           select d.giangVienHuongDan.id as giangVienId, count(d) as soDeTai
           from DeTai d
           where d.giangVienHuongDan.id in :gvIds
             and d.trangThai in ('DA_DUYET')
           group by d.giangVienHuongDan.id
           """)
    List<GiangVienLoad> countActiveByGiangVienIds(Collection<Long> gvIds);

    Optional<DeTai> findDeTaiBySinhVien_Id(Long sinhVien);
    Page<DeTai> findByGiangVienHuongDan_IdAndTrangThai(Long giangVienId, TrangThaiDeTai trangThai, Pageable pageable);
    Optional<DeTai> findBySinhVien_User_EmailIgnoreCase(String email);

    Optional<DeTai> findByTenDeTaiIgnoreCaseAndSinhVien_MaSinhVienIgnoreCase(String tenDeTai, String sinhVienThucHienMaSV);
    List<DeTai> findBySinhVien_MaSinhVienIgnoreCaseAndDotBaoVe_IdAndTrangThai(String maSv, Long dotId, TrangThaiDeTai trangThai);

    Optional<DeTai> findByNhatKyTienTrinhs_Id(Long nhatKyId);

    List<DeTai> findByGiangVienHuongDan_User_EmailIgnoreCase(String email);

    Optional<DeTai> findBySinhVien_MaSinhVienIgnoreCase(String maSinhVien);

}