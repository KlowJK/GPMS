package com.backend.gpms.common.mapper;

import com.backend.gpms.features.lecturer.domain.GiangVien;
import com.backend.gpms.features.student.domain.SinhVien;
import com.backend.gpms.features.topic.domain.DeTai;
import com.backend.gpms.features.topic.dto.request.DeTaiRequest;
import com.backend.gpms.features.topic.dto.response.DeTaiResponse;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import org.mapstruct.Named;
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
    @Mapping(source = "fileTongQuan", target = "noiDungDeTaiUrl", ignore = true)
    DeTai toDeTai(DeTaiRequest request);

    // Entity -> Response
    @Mapping(source = "giangVienHuongDan.id", target = "gvhdId")
    @Mapping(source = "giangVienHuongDan",          target = "gvhdTen", qualifiedByName = "gvDisplayName")
    @Mapping(source = "sinhVien.id", target = "sinhVienId")
    @Mapping(source = "noiDungDeTaiUrl", target = "tongQuanDeTaiUrl")
    @Mapping(source = "noiDungDeTaiUrl", target = "tongQuanFilename", qualifiedByName = "extractFilenameFromUrl")
    DeTaiResponse toDeTaiResponse(DeTai entity);

    @Mapping(source = "gvhdId", target = "giangVienHuongDan")
    @Mapping(target = "trangThai", ignore = true)
    @Mapping(target = "nhanXet", ignore = true)
    @Mapping(target = "sinhVien", ignore = true)
    @Mapping(source = "fileTongQuan", target = "noiDungDeTaiUrl", ignore = true)
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

    @Named("extractFilenameFromUrl")
    default String extractFilenameFromUrl(String url) {
        if (url == null) return null;
        int lastSlash = url.lastIndexOf('/');
        return lastSlash >= 0 ? url.substring(lastSlash + 1) : url;
    }

    @Named("gvDisplayName")
    default String gvDisplayName(GiangVien gv) {
        if (gv == null) return null;
        StringBuilder sb = new StringBuilder();
        // thêm học hàm rồi học vị (có khoảng trắng nếu tồn tại)
        if (gv.getHocHam() != null && !gv.getHocHam().isBlank()) {
            sb.append(gv.getHocHam().trim()).append(' ');
        }
        if (gv.getHocVi() != null && !gv.getHocVi().isBlank()) {
            sb.append(gv.getHocVi().trim()).append(' ');
        }
        if (gv.getHoTen() != null && !gv.getHoTen().isBlank()) {
            sb.append(gv.getHoTen().trim());
        }
        // gom khoảng trắng thừa & trim cuối
        return sb.toString().replaceAll("\\s+", " ").trim();
    }
}