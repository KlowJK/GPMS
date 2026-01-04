package com.backend.gpms.common.mapper;

import com.backend.gpms.features.defense.domain.ThoiGianThucHien;
import com.backend.gpms.features.defense.dto.request.ThoiGianThucHienRequest;
import com.backend.gpms.features.defense.dto.response.ThoiGianThucHienResponse;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import org.mapstruct.ReportingPolicy;

@Mapper(
        componentModel = "spring",
        unmappedSourcePolicy = ReportingPolicy.IGNORE
)
public interface ThoiGianThucHienMapper {

    @Mapping(target = "tenDotBaoVe", source = "dotBaoVe.tenDot")
    ThoiGianThucHienResponse toThoiGianThucHienResponse(ThoiGianThucHien thoiGianThucHien);
    @Mapping(target = "dotBaoVe.id", source = "dotBaoVeId")
    ThoiGianThucHien toThoiGianThucHien(ThoiGianThucHienRequest thoiGianThucHienRequest);

    void updateThoiGianThucHienFromDto(ThoiGianThucHienRequest thoiGianThucHienRequest,@MappingTarget ThoiGianThucHien entity);

}