package com.backend.gpms.features.topic.domain;

import com.backend.gpms.common.util.BaseEntity;
import com.backend.gpms.features.auth.domain.User;
import com.backend.gpms.features.student.domain.SinhVien;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDateTime;

@Entity
@Table(name = "don_hoan_do_an",
        indexes = {
                @Index(name="idx_dhda_sv", columnList = "id_sinh_vien"),
                @Index(name="idx_dhda_phe_duyet", columnList = "id_nguoi_phe_duyet"),
                @Index(name = "idx_dhda_trang_thai", columnList = "trang_thai")
        })
@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
public class DonHoanDoAn extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id;

    @Column(name="ly_do")
    String lyDo;

    @Column(name="ghi_chu")
    String ghiChuQuyetDinh;

    @Column(name="minh_chung_url")
    String minhChungUrl;

    @Enumerated(EnumType.STRING)
    @Column(name="trang_thai", nullable=false, columnDefinition="tt_duyet_don")
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    TrangThaiDeTai trangThai;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_sinh_vien", nullable = false)
    SinhVien sinhVien;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_nguoi_phe_duyet")
    User nguoiPheDuyet;


}
