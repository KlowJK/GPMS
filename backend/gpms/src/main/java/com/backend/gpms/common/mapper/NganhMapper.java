package com.backend.gpms.common.mapper;


import com.backend.gpms.features.department.domain.Khoa;
import com.backend.gpms.features.department.domain.Nganh;
import com.backend.gpms.features.department.dto.request.NganhRequest;
import com.backend.gpms.features.department.dto.response.NganhResponse;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.ReportingPolicy;

@Mapper(
        componentModel = "spring",
        unmappedSourcePolicy = ReportingPolicy.IGNORE
)
public interface NganhMapper {

    @Mapping(source = "khoa", target = "khoaId")
    NganhResponse toNganhResponse(Nganh nganh);

    @Mapping(source = "khoaId", target = "khoa")
    Nganh toNganh(NganhRequest nganhRequest);

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
