package com.backend.gpms.features.notification.domain;


import com.backend.gpms.common.util.BaseEntity;
import jakarta.persistence.*;
import lombok.Getter; import lombok.Setter;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import java.time.OffsetDateTime;

@Getter @Setter
@Entity @Table(name="thong_bao")
public class ThongBao extends BaseEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    @Column(name="noi_dung", nullable=false, columnDefinition="text") private String noiDung;
    @Column(name="thoi_gian_gui", nullable=false) private OffsetDateTime thoiGianGui = OffsetDateTime.now();

    @Enumerated(EnumType.STRING)
    @Column(name="loai", nullable=false, columnDefinition="loai_thong_bao")
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    private LoaiThongBao loai = LoaiThongBao.HE_THONG;
}