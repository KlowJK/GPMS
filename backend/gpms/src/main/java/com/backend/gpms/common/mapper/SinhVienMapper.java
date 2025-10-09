package com.backend.gpms.common.mapper;

import com.backend.gpms.features.lecturer.dto.response.ApprovalSinhVienResponse;
import com.backend.gpms.features.lecturer.dto.response.SinhVienSupervisedResponse;
import com.backend.gpms.features.student.domain.SinhVien;
import com.backend.gpms.features.student.dto.request.SinhVienCreateRequest;
import com.backend.gpms.features.student.dto.request.SinhVienCreationRequest;
import com.backend.gpms.features.student.dto.request.SinhVienUpdateRequest;
import com.backend.gpms.features.student.dto.response.GetSinhVienWithoutDeTaiResponse;
import com.backend.gpms.features.student.dto.response.SinhVienCreationResponse;
import com.backend.gpms.features.student.dto.response.SinhVienInfoResponse;
import com.backend.gpms.features.student.dto.response.SinhVienResponse;
import org.mapstruct.*;
import com.backend.gpms.features.department.domain.Lop;



@Mapper(
        componentModel = "spring",
        unmappedTargetPolicy = ReportingPolicy.IGNORE,
        nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE
)
public interface SinhVienMapper {

    // Chỉ map các field primitive; quan hệ (lop, user) sẽ set ở Service
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "lop", ignore = true)  // Lop là @ManyToOne
    @Mapping(target = "user",  ignore = true)  // User là @OneToOne
    @Mapping(target = "duDieuKien", ignore = true) // set theo req ở service
    @Mapping(target = "duongDanAvt", ignore = true)
    SinhVien toSinhVien(SinhVienCreateRequest req);

    @Mapping(target = "user.email",  source = "email")
    @Mapping(target = "user.vaiTro", expression = "java(com.backend.gpms.features.auth.domain.Role.SINH_VIEN)")
    @Mapping(target = "lop", source = "idLop")
    SinhVien toSinhVien(SinhVienCreationRequest request);

    @Mapping(source = "maSinhVien", target = "maSV")
    @Mapping(source = "user.email", target = "email")
    @Mapping(source = "lop", target = "lopId")
    SinhVienCreationResponse toSinhVienCreationResponse(SinhVien sinhVien);

    @Mapping(source = "user.email", target = "email")
    @Mapping(source = "lop.tenLop", target = "tenLop")
    @Mapping(source = "maSinhVien", target = "maSV")
    @Mapping(source = "duDieuKien", target = "kichHoat")
    SinhVienResponse toSinhVienResponse(SinhVien sinhVien);

    @Mapping(source = "maSinhVien" , target = "maSV")
    @Mapping(source = "lop.tenLop", target = "tenLop")
    @Mapping(source = "deTai.tenDeTai", target = "tenDeTai")
    @Mapping(source = "duongDanCv", target = "cvUrl")
    SinhVienSupervisedResponse toSinhVienSupervisedResponse(SinhVien sv);

    @Mapping(source = "maSinhVien" , target = "maSV")
    @Mapping(source = "lop.tenLop", target = "tenLop")
    @Mapping(source = "deTai.tenDeTai", target = "tenDeTai")
    @Mapping(source = "duongDanCv", target = "cvUrl")
    SinhVienSupervisedResponse toStudentSupervisedResponse(SinhVien sv);

    @Mapping(source = "maSinhVien" , target = "maSV")
    @Mapping(source = "deTai.id", target = "idDeTai")
    @Mapping(source = "lop.tenLop", target = "tenLop")
    @Mapping(source = "deTai.tenDeTai", target = "tenDeTai")
    @Mapping(source = "deTai.trangThai", target = "trangThai")
    @Mapping(source = "deTai.noiDungDeTaiUrl", target = "tongQuanDeTaiUrl")
    @Mapping(source = "deTai.nhanXet", target = "nhanXet")
    ApprovalSinhVienResponse toDeTaiSinhVienApprovalResponse(SinhVien sv);

    @Mapping(source = "maSinhVien" , target = "maSV")
    @Mapping(source = "lop.tenLop", target = "tenLop")
    @Mapping(source = "user.email", target = "email")
    @Mapping(source = "lop.nganh.khoa.tenKhoa", target = "tenKhoa")
    @Mapping(source = "lop.nganh.tenNganh", target = "tenNganh")
    @Mapping(source = "duongDanCv", target = "cvUrl")
    SinhVienInfoResponse toSinhVienInfoResponse(SinhVien sv);

    @Mapping(source = "maSinhVien" , target = "maSV")
    GetSinhVienWithoutDeTaiResponse toGetSinhVienWithoutDeTaiResponse(SinhVien sv);

    default Lop map(Long lopId) {
        if (lopId == null) return null;
        Lop lop = new Lop();
        lop.setId(lopId);
        return lop;
    }

    default Long map(Lop lop) {
        return lop != null ? lop.getId() : null;
    }

}
