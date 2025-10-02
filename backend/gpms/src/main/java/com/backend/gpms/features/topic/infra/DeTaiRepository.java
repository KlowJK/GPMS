package  com.backend.gpms.features.topic.infra;

import com.backend.gpms.features.lecturer.infra.GiangVienLoad;
import com.backend.gpms.features.topic.domain.DeTai;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

public interface DeTaiRepository extends JpaRepository<DeTai, Long> {
    Optional<DeTai> findById(Long id);

    @Query("""
           select d.idGiangVienHuongDan as giangVienId, count(d) as soDeTai
           from DeTai d
           where d.idGiangVienHuongDan in :gvIds
             and d.trangThai in ('DA_DUYET','DANG_THUC_HIEN')
           group by d.idGiangVienHuongDan
           """)
    List<GiangVienLoad> countActiveByGiangVienIds(Collection<Long> gvIds);
}