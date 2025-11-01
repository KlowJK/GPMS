package com.backend.gpms.features.council.domain;

import com.backend.gpms.common.util.BaseEntity;
import com.backend.gpms.features.lecturer.domain.GiangVien;
import com.backend.gpms.features.topic.domain.DeTai;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;


@Getter
@Setter
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
@Entity
@Table(
        name = "phan_cong_phan_bien",
        indexes = {
                @Index(name = "idx_phan_cong_phan_bien_de_tai", columnList = "id_de_tai"),
                @Index(name = "idx_phan_cong_phan_bien_gv", columnList = "id_giang_vien")
        }
)
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class PhanCongPhanBien extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name="id_de_tai", nullable=false)
    DeTai deTai;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name="id_giang_vien", nullable=false)
    GiangVien giangVien;

    @Enumerated(EnumType.STRING)
    @Column(name="vai_tro", nullable=false, columnDefinition="vai_tro_pb")
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    VaiTroPhanBien vaiTro;

}
