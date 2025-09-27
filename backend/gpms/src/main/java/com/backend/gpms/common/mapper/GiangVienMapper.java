package com.backend.gpms.common.mapper;
import com.backend.gpms.features.auth.domain.Role;
import com.backend.gpms.features.department.domain.BoMon;
import com.backend.gpms.features.lecturer.domain.GiangVien;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.ReportingPolicy;

@Mapper(
        componentModel = "spring",
        unmappedSourcePolicy = ReportingPolicy.IGNORE
)
public interface GiangVienMapper {

    @Mapping(target = "tai_khoan.email", source = "email")
    @Mapping(target = "tai_khoan.mat_khau", ignore = true)
    @Mapping(target = "bo_mon", source = "id_bo_mon")
    GiangVien toGiangVien(GiangVienCreationRequest request);

    @Mapping(source = "taiKhoan.email", target = "email")
    @Mapping(source = "taiKhoan.vaiTro", target = "vaiTro")
    @Mapping(source = "boMon", target = "boMonId")
    GiangVienCreationResponse toGiangVienCreationResponse(GiangVien entity);

    GiangVienInfoResponse toGiangVienInfoResponse(GiangVien entity);

    GiangVienLiteResponse toLite(GiangVien entity);

    @Mapping(source = "taiKhoan.email", target = "email")
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