package com.backend.gpms.common.mapper;

import com.backend.gpms.features.council.dto.response.ThanhVienHoiDongResponse.SinhVienTrongHoiDong;
import com.backend.gpms.features.council.domain.HoiDong;
import com.backend.gpms.features.council.domain.ThanhVienHoiDong;
import com.backend.gpms.features.council.dto.response.HoiDongResponse;
import com.backend.gpms.features.council.dto.response.ThanhVienHoiDongResponse;
import com.backend.gpms.features.lecturer.domain.GiangVien;
import com.backend.gpms.features.student.domain.SinhVien;
import com.backend.gpms.features.topic.domain.DeTai;
import org.mapstruct.*;
import org.mapstruct.ReportingPolicy;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

@Mapper(
        componentModel = "spring",
        unmappedSourcePolicy = ReportingPolicy.IGNORE
)
public interface HoiDongMapper {


    HoiDongResponse toListItem(HoiDong entity);


    @Mapping(source = "chuTich.hoTen", target = "chuTich")
    @Mapping(source = "thuKy.hoTen",target = "thuKy")
    @Mapping(source = "thanhVienHoiDongSet", target = "giangVienPhanBien", qualifiedByName = "mapThanhVienHoiDongSetToGiangVienPhanBien")
    @Mapping(target = "sinhVienList", expression = "java(toSinhVienList(entity.getDeTaiSet()))")
    ThanhVienHoiDongResponse toDetail(HoiDong entity);

    @Named("mapThanhVienHoiDongSetToGiangVienPhanBien")
    default List<String> mapThanhVienHoiDongSetToGiangVienPhanBien(Set<ThanhVienHoiDong> set) {
        if (set == null) return List.of();
        List<String> out = new ArrayList<>();
        for (ThanhVienHoiDong tv : set) {
            if (tv == null || tv.getGiangVien() == null) continue;
            String name = tv.getGiangVien().getHoTen();
            if (name != null && !name.isBlank()) out.add(name);
        }
        return out;
    }

    @Named("enumName")
    default String enumName(Enum<?> e) {
        return e != null ? e.name() : null;
    }

    default List<SinhVienTrongHoiDong> toSinhVienList(Set<DeTai> deTais) {
        if (deTais == null) return List.of();
        List<SinhVienTrongHoiDong> out = new ArrayList<>();
        for (DeTai dt : deTais) {
            if (dt == null) continue;
            SinhVien sv = dt.getSinhVien();
            String lop = (sv != null && sv.getLop() != null) ? sv.getLop().getTenLop() : null;
            String gvhd = (dt.getGiangVienHuongDan()!= null) ? dt.getGiangVienHuongDan().getHoTen() : null;
            String boMon = (dt.getGiangVienHuongDan() != null && dt.getGiangVienHuongDan().getBoMon() != null)
                    ? dt.getGiangVienHuongDan().getBoMon().getTenBoMon() : null;

            out.add(SinhVienTrongHoiDong.builder()
                    .hoTen(sv != null ? sv.getHoTen() : null)
                    .maSV(sv != null ? sv.getMaSinhVien() : null)
                    .lop(lop)
                    .tenDeTai(dt.getTenDeTai())
                    .gvhd(gvhd)
                    .boMon(boMon)
                    .build());
        }
        return out;
    }

    @AfterMapping
    default void fillRoles(HoiDong src,
                           @MappingTarget ThanhVienHoiDongResponse.ThanhVienHoiDongResponseBuilder target) {
        if (src.getThanhVienHoiDongSet() == null) return;

        String chuTich = null;
        String thuKy = null;
        List<String> examiners = new ArrayList<>();

        for (ThanhVienHoiDong tv : src.getThanhVienHoiDongSet()) {
            if (tv == null) continue;
            GiangVien gv = (tv.getGiangVien() != null)
                    ? tv.getGiangVien() : null;
            String name = (gv != null) ? gv.getHoTen() : null;
            if (name == null || name.isBlank()) continue;

        }
    }
}
