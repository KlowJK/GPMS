package  com.backend.gpms.features.topic.infra;

import com.backend.gpms.features.topic.domain.DeTai;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface DeTaiRepository extends JpaRepository<DeTai, Long> {
    Optional<DeTai> findById(Long id);
}