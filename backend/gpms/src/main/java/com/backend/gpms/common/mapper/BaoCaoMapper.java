package com.backend.gpms.common.mapper;

import com.backend.gpms.features.progress.domain.BaoCao;
import com.backend.gpms.features.progress.dto.request.BaoCaoRequest;
import com.backend.gpms.features.progress.dto.response.BaoCaoResponse;
import org.mapstruct.*;
import org.springframework.web.multipart.MultipartFile;

@Mapper(
        componentModel = "spring",
        unmappedTargetPolicy = ReportingPolicy.IGNORE,
        nullValueCheckStrategy = NullValueCheckStrategy.ALWAYS,
        nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE
)
public interface BaoCaoMapper {
    @Mapping(target = "duongDanFile", source = "duongDanFile", qualifiedByName = "multipartFileToString")
    BaoCao toBaoCao(BaoCaoRequest request);

    @Mapping(source = "deTai.tenDeTai", target = "tenDeTai")
    @Mapping(source = "deTai.id", target = "idDeTai")
    @Mapping(source = "deTai.sinhVien.maSinhVien", target = "maSinhVien")
    @Mapping(source = "deTai.giangVienHuongDan.hoTen", target = "tenGiangVienHuongDan")
    @Mapping(source = "diemHuongDan", target = "diemBaoCao")
    @Mapping(source = "createdAt", target = "ngayNop")
    @Mapping(source = "ghiChu", target = "nhanXet")
    @Mapping(source = "deTai.sinhVien.hoTen", target = "tenSinhVien")
    @Mapping(source = "createdAt", target = "createdAt")
    @Mapping(source = "deTai.sinhVien.lop.tenLop", target = "lop")
    BaoCaoResponse toBaoCaoResponse(BaoCao baoCao);

    @Named("multipartFileToString")
    default String multipartFileToString(MultipartFile file) {
        return file != null ? file.getOriginalFilename() : null;
    }
}
