package com.backend.gpms.common.mapper;

import com.backend.gpms.features.department.domain.Khoa;
import com.backend.gpms.features.department.dto.request.KhoaRequest;
import com.backend.gpms.features.department.dto.response.KhoaResponse;
import org.mapstruct.Mapper;
import org.mapstruct.ReportingPolicy;

@Mapper(
        componentModel = "spring",
        unmappedSourcePolicy = ReportingPolicy.IGNORE
)
public interface KhoaMapper {
    KhoaResponse toKhoaResponse(Khoa khoa);
    Khoa toKhoa(KhoaRequest khoaRequest);
}

