package com.backend.gpms.common.mapper;

import com.backend.gpms.features.lecturer.domain.GiangVien;
import com.backend.gpms.features.student.domain.SinhVien;
import com.backend.gpms.features.topic.domain.DeTai;
import com.backend.gpms.features.topic.dto.request.DeTaiRequest;
import com.backend.gpms.features.topic.dto.response.DeTaiResponse;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import org.mapstruct.ReportingPolicy;

@Mapper(
        componentModel = "spring",
        unmappedSourcePolicy = ReportingPolicy.IGNORE
)
public interface DeTaiMapper {

    // Request -> Entity
    @Mapping(source = "gvhdId", target = "giangVienHuongDan")
    @Mapping(target = "trangThai", ignore = true)
    @Mapping(target = "nhanXet", ignore = true)
    @Mapping(target = "sinhVien", ignore = true)
    @Mapping(target = "noiDungDeTaiUrl", ignore = true)

    DeTai toDeTai(DeTaiRequest request);

    // Entity -> Response
    @Mapping(source = "giangVienHuongDan.hoTen", target = "gvhdTen")
    @Mapping(source = "giangVienHuongDan", target = "gvhdId")
    @Mapping(source = "sinhVien", target = "sinhVienId")
    DeTaiResponse toDeTaiResponse(DeTai entity);

    @Mapping(source = "gvhdId", target = "giangVienHuongDan")
    @Mapping(target = "trangThai", ignore = true)
    @Mapping(target = "nhanXet", ignore = true)
    @Mapping(target = "sinhVien", ignore = true)
    @Mapping(target = "noiDungDeTaiUrl", ignore = true)
    void update(DeTaiRequest request, @MappingTarget DeTai entity);

    // Convert GiangVien and SinhVien to their IDs
    default Long toId(GiangVien gv) { return gv != null ? gv.getId() : null; }
    default Long toId(SinhVien sv) { return sv != null ? sv.getId() : null; }

    default GiangVien toGiangVien(Long id) {
        if (id == null) return null;
        GiangVien g = new GiangVien();
        g.setId(id);
        return g;
    }
}