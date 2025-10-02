package com.backend.gpms.common.mapper;
import com.backend.gpms.features.auth.domain.Role;
import com.backend.gpms.features.department.domain.BoMon;
import com.backend.gpms.features.lecturer.domain.GiangVien;
import com.backend.gpms.features.lecturer.dto.response.GiangVienResponse;
import com.backend.gpms.features.lecturer.dto.response.GiangVienLiteResponse;
import com.backend.gpms.features.lecturer.dto.response.GiangVienInfoResponse;
import com.backend.gpms.features.lecturer.dto.request.GiangVienCreationRequest;
import com.backend.gpms.features.lecturer.dto.response.GiangVienCreationResponse;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.NullValuePropertyMappingStrategy;
import org.mapstruct.ReportingPolicy;

@Mapper(
        componentModel = "spring",
        unmappedSourcePolicy = ReportingPolicy.IGNORE,
        nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE
)
public interface GiangVienMapper {

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "idBoMon", ignore = true) // đúng tên field trong entity của bạn
    @Mapping(target = "user",   ignore = true)
    @Mapping(target = "duongDanAvt", ignore = true)
    GiangVien toGiangVien(GiangVienCreationRequest request);

}