package com.backend.gpms.features.student.domain;

import com.backend.gpms.features.defense.domain.DotBaoVe;
import com.backend.gpms.features.department.domain.Lop;
import com.backend.gpms.features.department.domain.Nganh;
import com.backend.gpms.features.topic.domain.DeTai;
import com.backend.gpms.features.topic.domain.TrangThaiDeTai;
import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.JoinType;
import org.springframework.data.jpa.domain.Specification;

public class SinhVienSpecification {

    public static Specification<SinhVien> belongsToBoMonAndDotBaoVe(Long idBoMon, DotBaoVe dotBaoVe) {
        return (root, query, cb) -> {
            Join<SinhVien, Lop> lopJoin = root.join("lop");
            Join<Lop, Nganh> nganhJoin = lopJoin.join("nganh");
            return cb.equal(nganhJoin.get("boMon").get("id"), idBoMon);
        };
    }

    public static Specification<SinhVien> hasStatusOrNotRegistered(TrangThaiDeTai status, DotBaoVe dotBaoVe) {
        return (root, query, cb) -> {
            if (status == null) return cb.conjunction();

            Join<SinhVien, DeTai> deTaiJoin = root.join("deTai", JoinType.LEFT);

            if (status == TrangThaiDeTai.TU_CHOI) {
                return cb.and(
                        cb.or(cb.isNull(deTaiJoin), cb.equal(deTaiJoin.get("dotBaoVe"), dotBaoVe)),
                        cb.or(cb.isNull(deTaiJoin), cb.equal(deTaiJoin.get("trangThai"), TrangThaiDeTai.TU_CHOI))
                );
            } else {
                return cb.and(
                        cb.isNotNull(deTaiJoin),
                        cb.equal(deTaiJoin.get("dotBaoVe"), dotBaoVe),
                        cb.equal(deTaiJoin.get("trangThai"), status)
                );
            }
        };
    }
}