package com.backend.gpms.common.mapper;

import com.backend.gpms.features.outline.domain.DeCuong;
import com.backend.gpms.features.outline.dto.request.DeCuongRequest;
import com.backend.gpms.features.outline.dto.response.DeCuongResponse;
import com.backend.gpms.features.topic.domain.DeTai;
import org.mapstruct.*;

import java.util.List;

@Mapper(
        componentModel = "spring",
        unmappedTargetPolicy = ReportingPolicy.IGNORE,
        nullValueCheckStrategy = NullValueCheckStrategy.ALWAYS,
        nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE
)
public interface DeCuongMapper {

    // Entity -> Response
    @Mappings({
            @Mapping(source = "deTai.tenDeTai",               target = "tenDeTai"),
            @Mapping(source = "deTai.sinhVien.maSinhVien",  target = "maSV"),
            @Mapping(source = "deTai.sinhVien.hoTen", target = "hoTenSinhVien"),
            @Mapping(source = "deTai.giangVienHuongDan.hoTen",      target = "hoTenGiangVien"),
            @Mapping(source = "phienBan",                     target = "soLanNop"),
            @Mapping(source = "duongDanFile",                   target = "deCuongUrl"),
    })
    DeCuongResponse toResponse(DeCuong entity);

    List<DeCuongResponse> toResponse(List<DeCuong> entities);

    // Request -> Entity (tạo mới)
    @Mapping(source = "deTaiId", target = "deTai", qualifiedByName = "idToDeTai")
    @Mapping(source = "fileUrl",  target = "duongDanFile")
    DeCuong toEntity(DeCuongRequest request);

    // Cập nhật in-place (nộp lại → set PENDING làm ở service)
    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    @Mapping(source = "deTaiId", target = "deTai", qualifiedByName = "idToDeTai")
    @Mapping(source = "fileUrl",  target = "duongDanFile")
    void update(@MappingTarget DeCuong target, DeCuongRequest request);

    // ===== Helpers =====
    @Named("idToDeTai")
    default DeTai idToDeTai(Long id) {
        if (id == null) return null;
        DeTai dt = new DeTai();
        dt.setId(id);
        return dt;
    }
}
