package com.backend.gpms.common.mapper;

import com.backend.gpms.features.department.domain.BoMon;
import com.backend.gpms.features.department.domain.Khoa;
import com.backend.gpms.features.department.dto.request.BoMonRequest;
import com.backend.gpms.features.department.dto.response.BoMonResponse;
import com.backend.gpms.features.department.dto.response.BoMonWithTruongBoMonResponse;
import com.backend.gpms.features.department.dto.response.TruongBoMonCreationResponse;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.ReportingPolicy;

@Mapper(
        componentModel = "spring",
        unmappedSourcePolicy = ReportingPolicy.IGNORE
)
public interface BoMonMapper {
    @Mapping(source = "khoaId", target = "khoa")
    BoMon toBoMon(BoMonRequest request);
    @Mapping(source = "khoa", target = "khoaId")
    BoMonResponse toBoMonResponse(BoMon boMon);

    @Mapping(target = "maGV",   source = "truongBoMon.maGiangVien")
    @Mapping(target = "hoTen",  source = "truongBoMon.hoTen")
    @Mapping(target = "hocVi",  source = "truongBoMon.hocVi")
    @Mapping(target = "hocHam", source = "truongBoMon.hocHam")
    @Mapping(target = "tenBoMon", source = "tenBoMon")
    TruongBoMonCreationResponse toTruongBoMonCreationResponse(BoMon boMon);

    @Mapping(target = "khoaId", source = "khoa.id")
    @Mapping(target = "tenKhoa", source = "khoa.tenKhoa")
    @Mapping(target = "truongBoMonHoTen",
            expression = "java(boMon.getTruongBoMon() != null ? boMon.getTruongBoMon().getHoTen() : null)")
    BoMonWithTruongBoMonResponse toWithTruongBoMon(BoMon boMon);

    default Long toId(Khoa khoa) {
        return (khoa != null) ? khoa.getId() : null;
    }

    default Khoa toKhoa(Long id) {
        if (id == null) return null;
        Khoa k = new Khoa();
        k.setId(id);
        return k;
    }
}

