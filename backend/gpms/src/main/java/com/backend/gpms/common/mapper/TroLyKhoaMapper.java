package com.backend.gpms.common.mapper;

import com.backend.gpms.features.account.domain.TroLyKhoa;
import com.backend.gpms.features.account.dto.response.TroLyKhoaResponse;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(    componentModel = "spring",
        unmappedTargetPolicy = org.mapstruct.ReportingPolicy.IGNORE
)
public interface TroLyKhoaMapper {

    @Mapping(source = "user.id", target = "idTaiKhoan")
    @Mapping(source = "user.email", target = "email")
    @Mapping(source = "user.vaiTro", target = "vaiTro")
    TroLyKhoaResponse toTroLyKhoaResponse(TroLyKhoa entity);
}
