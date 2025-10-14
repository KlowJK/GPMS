package com.backend.gpms.features.notification.domain;


import com.backend.gpms.common.util.BaseEntity;
import jakarta.persistence.*;
import lombok.Getter; import lombok.Setter;
import lombok.experimental.FieldDefaults;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import java.time.OffsetDateTime;
import java.util.List;

@Getter @Setter
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
@Entity @Table(name="thong_bao")
public class ThongBao extends BaseEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id;

    @Column(name="noi_dung", nullable=false, columnDefinition="text")
    String noiDung;

    @Column(name="thoi_gian_gui", nullable=false)
    OffsetDateTime thoiGianGui = OffsetDateTime.now();

    @Enumerated(EnumType.STRING)
    @Column(name="loai", nullable=false, columnDefinition="loai_thong_bao")
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    LoaiThongBao loai = LoaiThongBao.HE_THONG;

    @OneToMany(mappedBy = "thongBao")
    List<ThongBaoDen> thongBaoDens;
}