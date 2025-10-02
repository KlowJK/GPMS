package com.backend.gpms.common.mapper;

import com.backend.gpms.features.student.domain.SinhVien;
import com.backend.gpms.features.student.dto.request.SinhVienCreateRequest;
import com.backend.gpms.features.student.dto.request.SinhVienUpdateRequest;
import com.backend.gpms.features.student.dto.response.SinhVienResponse;
import org.mapstruct.*;
import com.backend.gpms.features.department.domain.Lop;
import com.backend.gpms.features.department.infra.LopRepository;


@Mapper(
        componentModel = "spring",
        unmappedTargetPolicy = ReportingPolicy.IGNORE,
        nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE
)
public interface SinhVienMapper {

    // Chỉ map các field primitive; quan hệ (lop, user) sẽ set ở Service
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "idLop", ignore = true)  // Lop là @ManyToOne
    @Mapping(target = "user",  ignore = true)  // User là @OneToOne
    @Mapping(target = "duDieuKien", ignore = true) // set theo req ở service
    @Mapping(target = "duongDanAvt", ignore = true)
    SinhVien toSinhVien(SinhVienCreateRequest req);

}
