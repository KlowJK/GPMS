package com.backend.gpms.common.mapper;

import com.backend.gpms.features.lecturer.domain.GiangVien;
import com.backend.gpms.features.lecturer.dto.request.GiangVienCreationRequest;


import org.mapstruct.*;

@Mapper(
        componentModel = "spring",
        unmappedSourcePolicy = ReportingPolicy.IGNORE,
        nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE
)
public interface GiangVienMapper {

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "boMon", ignore = true)
    @Mapping(target = "user",   ignore = true)
    @Mapping(target = "duongDanAvt", ignore = true)
    GiangVien toGiangVien(GiangVienCreationRequest request);

}