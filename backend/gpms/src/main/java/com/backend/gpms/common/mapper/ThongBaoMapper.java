package com.backend.gpms.common.mapper;


import com.backend.gpms.features.notification.domain.ThongBao;
import com.backend.gpms.features.notification.dto.request.ThongBaoRequest;
import com.backend.gpms.features.notification.dto.response.ThongBaoResponse;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.ReportingPolicy;

@Mapper(
        componentModel = "spring",
        unmappedSourcePolicy = ReportingPolicy.IGNORE
)
public interface ThongBaoMapper {


    @Mapping(source = "createdAt", target = "createdAt")
    @Mapping(source = "file", target = "fileUrl")
    ThongBaoResponse toThongBaoResponse(ThongBao entity);

    @Mapping(target = "file", ignore = true)
    ThongBao toThongBao(ThongBaoRequest thongBaoRequest);
}
