package com.backend.gpms.common.mapper;

import com.backend.gpms.features.auth.domain.User;
import com.backend.gpms.features.student.domain.SinhVien;
import com.backend.gpms.features.topic.domain.DonHoanDoAn;
import com.backend.gpms.features.topic.dto.response.DonHoanDoAnResponse;
import org.mapstruct.*;

@Mapper(componentModel = "spring", unmappedSourcePolicy = ReportingPolicy.IGNORE)
public interface DonHoanDoAnMapper {

    @Mapping(source = "sinhVien.id", target = "sinhVienId")
    @Mapping(source = "nguoiPheDuyet.id", target = "nguoiPheDuyetId")
    @Mapping(source = "createdAt", target = "createdAt")
    @Mapping(source = "updatedAt", target = "updatedAt")
    DonHoanDoAnResponse toResponse(DonHoanDoAn entity);

    default Long toId(SinhVien x) { return x != null ? x.getId() : null; }
    default Long toId(User x) { return x != null ? x.getId() : null; }
}