package com.backend.gpms.common.mapper;

import com.backend.gpms.features.defense.domain.DotBaoVe;
import com.backend.gpms.features.defense.dto.request.DotBaoVeRequest;
import com.backend.gpms.features.defense.dto.response.DotBaoVeResponse;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import org.mapstruct.ReportingPolicy;

@Mapper(
        componentModel = "spring",
        unmappedSourcePolicy = ReportingPolicy.IGNORE
)
public interface DotBaoVeMapper {

    DotBaoVeResponse toDotBaoVeResponse(DotBaoVe request);
    DotBaoVe toDotBaoVe(DotBaoVeRequest request);

    void updateDotBaoVeFromDto(DotBaoVeRequest request, @MappingTarget DotBaoVe entity);

}