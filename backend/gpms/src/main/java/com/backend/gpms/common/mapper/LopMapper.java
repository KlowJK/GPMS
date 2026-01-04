package com.backend.gpms.common.mapper;

import com.backend.gpms.features.department.domain.Lop;
import com.backend.gpms.features.department.domain.Nganh;
import com.backend.gpms.features.department.dto.request.LopRequest;
import com.backend.gpms.features.department.dto.response.LopResponse;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.ReportingPolicy;

@Mapper(
        componentModel = "spring",
        unmappedSourcePolicy = ReportingPolicy.IGNORE
)
public interface LopMapper {

    @Mapping(source = "nganh", target = "nganhId")
    LopResponse toLopResponse(Lop lop);

    @Mapping(source = "nganhId", target = "nganh")
    Lop toLop(LopRequest lopRequest);

    default Long toId(Nganh nganh) {
        return (nganh != null) ? nganh.getId() : null;
    }

    default Nganh toNganh(Long id) {
        if (id == null) return null;
        Nganh nganh = new Nganh();
        nganh.setId(id);
        return nganh;
    }

}
