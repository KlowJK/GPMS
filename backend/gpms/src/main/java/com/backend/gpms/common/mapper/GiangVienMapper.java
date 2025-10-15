package com.backend.gpms.common.mapper;

import com.backend.gpms.features.auth.domain.Role;
import com.backend.gpms.features.department.domain.BoMon;
import com.backend.gpms.features.lecturer.domain.GiangVien;
import com.backend.gpms.features.lecturer.dto.request.GiangVienCreateRequest;

import com.backend.gpms.features.lecturer.dto.response.GiangVienCreationResponse;
import com.backend.gpms.features.lecturer.dto.response.GiangVienInfoResponse;
import com.backend.gpms.features.lecturer.dto.response.GiangVienLiteResponse;
import com.backend.gpms.features.lecturer.dto.response.GiangVienResponse;
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
    @Mapping(source = "idBoMon", target = "boMon.id")
    GiangVien toGiangVien(GiangVienCreateRequest request);

    @Mapping(source = "maGiangVien", target = "maGV")
    @Mapping(source = "user.email", target = "email")
    @Mapping(source = "user.vaiTro", target = "vaiTro")
    @Mapping(source = "boMon", target = "boMonId")
    GiangVienCreationResponse toGiangVienCreationResponse(GiangVien entity);

    @Mapping(source = "maGiangVien", target = "maGV")
    GiangVienInfoResponse toGiangVienInfoResponse(GiangVien entity);

    @Mapping(source = "boMon.id",       target = "boMonId")
    GiangVienLiteResponse toLite(GiangVien entity);

    @Mapping(source = "user.email", target = "email")
    @Mapping(source = "boMon.id",       target = "boMonId")
    GiangVienResponse toGiangVienResponse(GiangVien entity);

    default BoMon map(Long boMonId) {
        if (boMonId == null) return null;
        BoMon bm = new BoMon();
        bm.setId(boMonId);
        return bm;
    }

    default Long map(BoMon boMon) {
        return boMon != null ? boMon.getId() : null;
    }

    default Role mapRoleDefault(Role vaiTro) {
        return vaiTro != null ? vaiTro : Role.GIANG_VIEN;
    }

}