package com.backend.gpms.common.mapper;

import com.backend.gpms.features.student.domain.SinhVien;
import com.backend.gpms.features.student.dto.request.SinhVienCreateRequest;
import com.backend.gpms.features.student.dto.request.SinhVienUpdateRequest;
import com.backend.gpms.features.student.dto.response.SinhVienResponse;
import org.mapstruct.*;


@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface SinhVienMapper {
    @Mapping(source = "nganh.id", target = "nganh.id")
    @Mapping(source = "nganh.maNganh", target = "nganh.ma")
    @Mapping(source = "nganh.tenNganh", target = "nganh.ten")
    @Mapping(source = "lop.id", target = "lop.id")
    @Mapping(source = "lop.maLop", target = "lop.ma")
    @Mapping(source = "lop.tenLop", target = "lop.ten")
    @Mapping(source = "user.id", target = "userId")
    SinhVienResponse toResponse(SinhVien entity);

    // create: map ids từ request sang entity (resolver bởi service/repo)
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "nganh", ignore = true)
    @Mapping(target = "lop", ignore = true)
    @Mapping(target = "user", ignore = true)
    SinhVien toEntity(SinhVienCreateRequest req);

    // update: patch từng field
    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    @Mapping(target = "nganh", ignore = true)
    @Mapping(target = "lop", ignore = true)
    @Mapping(target = "user", ignore = true)
    void update(@MappingTarget SinhVien entity, SinhVienUpdateRequest req);
}
