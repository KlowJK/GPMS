package com.backend.gpms.common.mapper;


import com.backend.gpms.features.progress.domain.NhatKyTienTrinh;
import com.backend.gpms.features.progress.dto.request.NhatKyTienTrinhRequest;
import com.backend.gpms.features.progress.dto.response.NhatKyTienTrinhResponse;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;
import org.mapstruct.NullValuePropertyMappingStrategy;
import org.mapstruct.ReportingPolicy;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@Mapper(
        componentModel = "spring",
        unmappedTargetPolicy = ReportingPolicy.IGNORE,
        nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE
)
public interface NhatKyTienTrinhMapper {

    @Mapping(target = "duongDanFile", source = "duongDanFile", qualifiedByName = "mapMultipartFileToString")
    NhatKyTienTrinh toEntity(NhatKyTienTrinhRequest request);

    @Mapping(source = "nhatKyTienTrinh.deTai.sinhVien.maSinhVien", target = "maSinhVien")
    @Mapping(source = "nhatKyTienTrinh.deTai.sinhVien.hoTen", target = "hoTen")
    @Mapping(source = "nhatKyTienTrinh.deTai.sinhVien.lop.tenLop", target = "lop")
    @Mapping(source = "nhatKyTienTrinh.deTai.id", target = "idDeTai")
    @Mapping(source = "nhatKyTienTrinh.deTai.tenDeTai", target = "deTai")
    List<NhatKyTienTrinhResponse> toResponseList(List<NhatKyTienTrinh> entities);


    @Mapping(source = "nhatKyTienTrinh.deTai.sinhVien.maSinhVien", target = "maSinhVien")
    @Mapping(source = "nhatKyTienTrinh.deTai.sinhVien.hoTen", target = "hoTen")
    @Mapping(source = "nhatKyTienTrinh.deTai.sinhVien.lop.tenLop", target = "lop")
    @Mapping(source = "nhatKyTienTrinh.deTai.id", target = "idDeTai")
    @Mapping(source = "nhatKyTienTrinh.deTai.tenDeTai", target = "deTai")
    NhatKyTienTrinhResponse toNhatKyTienTrinhResponse(NhatKyTienTrinh nhatKyTienTrinh);


    @Named("mapMultipartFileToString")
    default String mapMultipartFileToString(MultipartFile file) {
        return file != null ? file.getOriginalFilename() : null;
    }
}
