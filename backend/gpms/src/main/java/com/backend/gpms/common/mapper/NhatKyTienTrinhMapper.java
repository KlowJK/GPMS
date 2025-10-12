package com.backend.gpms.common.mapper;


import com.backend.gpms.features.progress.domain.NhatKyTienTrinh;
import com.backend.gpms.features.progress.dto.request.NhatKyTienTrinhRequest;
import com.backend.gpms.features.progress.dto.response.NhatKyTienTrinhResponse;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;
import org.mapstruct.NullValuePropertyMappingStrategy;
import org.mapstruct.ReportingPolicy;
import org.springframework.data.domain.Page;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@Mapper(
        componentModel = "spring",
        unmappedTargetPolicy = ReportingPolicy.IGNORE,
        nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE
)
public interface NhatKyTienTrinhMapper {

    @Mapping(target = "duongDanFile", source = "duongDanFile", qualifiedByName = "mapMultipartFileToString")
    NhatKyTienTrinh toEntity(NhatKyTienTrinhRequest request);


    List<NhatKyTienTrinhResponse> toResponseList(List<NhatKyTienTrinh> entities);


    NhatKyTienTrinhResponse toNhatKyTienTrinhResponse(NhatKyTienTrinh nhatKyTienTrinh);

    @Named("mapMultipartFileToString")
    default String mapMultipartFileToString(MultipartFile file) {
        return file != null ? file.getOriginalFilename() : null;
    }
}
