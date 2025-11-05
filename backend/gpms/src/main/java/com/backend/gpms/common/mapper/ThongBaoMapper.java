package com.backend.gpms.common.mapper;


import com.backend.gpms.features.notification.domain.ThongBao;
import com.backend.gpms.features.notification.domain.ThongBaoDen;
import com.backend.gpms.features.notification.dto.request.ThongBaoRequest;
import com.backend.gpms.features.notification.dto.response.ThongBaoResponse;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;
import org.mapstruct.ReportingPolicy;

import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.util.List;

@Mapper(
        componentModel = "spring",
        unmappedSourcePolicy = ReportingPolicy.IGNORE
)
public interface ThongBaoMapper {


    @Mapping(target = "tieuDe", source = "tieuDe")
    @Mapping(target = "noiDung", source = "noiDung")
    @Mapping(target = "fileUrl", source = "file")
    @Mapping(target = "createdAt", source = "thoiGianGui", qualifiedByName = "offsetToLocal")
    @Mapping(target = "loaiThongBao", source = "loaiThongBao", qualifiedByName = "enumToString")
    @Mapping(target = "trangThai", source = "thongBaoDens", qualifiedByName = "extractTrangThai")
    ThongBaoResponse toThongBaoResponse(ThongBao entity);

    @Mapping(target = "file", ignore = true)
    ThongBao toThongBao(ThongBaoRequest thongBaoRequest);


    @Named("offsetToLocal")
    default LocalDateTime offsetToLocal(OffsetDateTime odt) {
        return odt == null ? null : odt.toLocalDateTime();
    }

    @Named("enumToString")
    default String enumToString(Enum<?> e) {
        return e == null ? null : e.name();
    }

    @Named("extractTrangThai")
    default String extractTrangThai(List<ThongBaoDen> dens) {
        if (dens == null || dens.isEmpty()) return null;
        for (ThongBaoDen d : dens) {
            if (d != null && d.getTrangThai() != null) {
                return d.getTrangThai().name();
            }
        }
        return null;
    }
}
