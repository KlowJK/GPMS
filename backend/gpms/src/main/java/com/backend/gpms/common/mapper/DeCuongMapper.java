package com.backend.gpms.common.mapper;

import com.backend.gpms.features.outline.domain.DeCuong;
import com.backend.gpms.features.outline.domain.NhanXetDeCuong;
import com.backend.gpms.features.outline.dto.request.DeCuongRequest;
import com.backend.gpms.features.outline.dto.response.DeCuongNhanXetResponse;
import com.backend.gpms.features.outline.dto.response.DeCuongResponse;
import com.backend.gpms.features.outline.dto.response.NhanXetDeCuongResponse;
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
            @Mapping(source = "deTai.sinhVien.maSinhVien",  target = "maSinhVien"),
            @Mapping(source = "deTai.sinhVien.hoTen", target = "hoTenSinhVien"),
            @Mapping(source = "deTai.tenDeTai",               target = "tenDeTai"),
            @Mapping(source = "giangVienHuongDan.hoTen",      target = "giangVienHuongDan"),
            @Mapping(source = "duongDanFile",                   target = "deCuongUrl"),
            @Mapping(source = "giangVienPhanBien.hoTen",      target = "giangVienPhanBien"),
            @Mapping(source = "truongBoMon.hoTen",      target = "truongBoMon"),
            @Mapping(source = "nhanXets", target = "nhanXets", qualifiedByName = "mapNhanXets")
    })
    DeCuongResponse toResponse(DeCuong entity);

    @Named("mapNhanXets")
    default List<DeCuongResponse.NhanXetDeCuongResponse> mapNhanXets(List<NhanXetDeCuong> nhanXets) {
        if (nhanXets == null) return null;
        return nhanXets.stream().map(this::mapNhanXet).toList();
    }

    @Named("mapNhanXet")
    default DeCuongResponse.NhanXetDeCuongResponse mapNhanXet(NhanXetDeCuong nhanXet) {
        if (nhanXet == null) return null;
        DeCuongResponse.NhanXetDeCuongResponse response = new DeCuongResponse.NhanXetDeCuongResponse();
        response.setNhanXet(nhanXet.getNhanXet());
        response.setHoTenGiangVien(nhanXet.getGiangVien() != null ? nhanXet.getGiangVien().getHoTen() : null);
        response.setCreatedAt(nhanXet.getCreatedAt()); // Giả sử BaseEntity có createdAt
        return response;
    }
    @Mapping(target = "id", source = "id")
    @Mapping(target = "deCuongUrl", source = "duongDanFile")
    @Mapping(target = "trangThai", source = "trangThaiDeCuong")
    @Mapping(target = "phienBan", source = "phienBan")
    @Mapping(target = "tenDeTai", source = "deTai.tenDeTai")
    @Mapping(target = "maSV", source = "deTai.sinhVien.maSinhVien")
    @Mapping(target = "hoTenSinhVien", source = "deTai.sinhVien.hoTen")
    @Mapping(target = "hoTenGiangVienHuongDan", source = "giangVienHuongDan.hoTen")
    @Mapping(target = "hoTenGiangVienPhanBien", source = "giangVienPhanBien.hoTen")
    @Mapping(target = "hoTenTruongBoMon", source = "truongBoMon.hoTen")
    @Mapping(target = "createdAt", source = "createdAt")
    @Mapping(target = "nhanXets", ignore = true) // set sau
    DeCuongNhanXetResponse toDeCuongNhanXetResponse(DeCuong entity);

    List<DeCuongNhanXetResponse> toDeCuongNhanXetResponse(List<DeCuong> entities);


    @Mapping(target = "nhanXet", source = "nhanXet")
    @Mapping(target = "idGiangVien", source = "giangVien.id")
    @Mapping(target = "hoTenGiangVien", source = "giangVien.hoTen")
    @Mapping(target = "createdAt", source = "createdAt")
    NhanXetDeCuongResponse toNhanXetDeCuongResponse(NhanXetDeCuong entity);

    List<NhanXetDeCuongResponse> toNhanXetDeCuongResponse(List<NhanXetDeCuong> entities);

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
