package com.backend.gpms.common.mapper;

import com.backend.gpms.features.auth.domain.User;
import com.backend.gpms.features.department.domain.Khoa;
import com.backend.gpms.features.department.domain.Lop;
import com.backend.gpms.features.department.domain.Nganh;
import com.backend.gpms.features.lecturer.dto.response.ApprovalSinhVienResponse;
import com.backend.gpms.features.lecturer.dto.response.SinhVienSupervisedResponse;
import com.backend.gpms.features.student.domain.SinhVien;
import com.backend.gpms.features.student.dto.request.SinhVienCreateRequest;
import com.backend.gpms.features.student.dto.request.SinhVienCreationRequest;
import com.backend.gpms.features.student.dto.response.GetSinhVienWithoutDeTaiResponse;
import com.backend.gpms.features.student.dto.response.SinhVienCreationResponse;
import com.backend.gpms.features.student.dto.response.SinhVienInfoResponse;
import com.backend.gpms.features.student.dto.response.SinhVienResponse;
import com.backend.gpms.features.topic.domain.DeTai;
import com.backend.gpms.features.topic.domain.TrangThaiDeTai;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-10-12T18:27:06+0700",
    comments = "version: 1.6.3, compiler: javac, environment: Java 21.0.4 (Oracle Corporation)"
)
@Component
public class SinhVienMapperImpl implements SinhVienMapper {

    @Override
    public SinhVien toSinhVien(SinhVienCreateRequest req) {
        if ( req == null ) {
            return null;
        }

        SinhVien.SinhVienBuilder sinhVien = SinhVien.builder();

        sinhVien.hoTen( req.getHoTen() );
        sinhVien.maSinhVien( req.getMaSinhVien() );
        sinhVien.soDienThoai( req.getSoDienThoai() );
        sinhVien.ngaySinh( req.getNgaySinh() );
        sinhVien.diaChi( req.getDiaChi() );

        return sinhVien.build();
    }

    @Override
    public SinhVien toSinhVien(SinhVienCreationRequest request) {
        if ( request == null ) {
            return null;
        }

        SinhVien.SinhVienBuilder sinhVien = SinhVien.builder();

        sinhVien.user( sinhVienCreationRequestToUser( request ) );
        sinhVien.lop( map( request.getIdLop() ) );
        sinhVien.hoTen( request.getHoTen() );
        sinhVien.maSinhVien( request.getMaSinhVien() );
        sinhVien.soDienThoai( request.getSoDienThoai() );

        return sinhVien.build();
    }

    @Override
    public SinhVienCreationResponse toSinhVienCreationResponse(SinhVien sinhVien) {
        if ( sinhVien == null ) {
            return null;
        }

        SinhVienCreationResponse.SinhVienCreationResponseBuilder sinhVienCreationResponse = SinhVienCreationResponse.builder();

        sinhVienCreationResponse.maSV( sinhVien.getMaSinhVien() );
        sinhVienCreationResponse.email( sinhVienUserEmail( sinhVien ) );
        sinhVienCreationResponse.lopId( map( sinhVien.getLop() ) );
        sinhVienCreationResponse.hoTen( sinhVien.getHoTen() );
        sinhVienCreationResponse.soDienThoai( sinhVien.getSoDienThoai() );

        return sinhVienCreationResponse.build();
    }

    @Override
    public SinhVienResponse toSinhVienResponse(SinhVien sinhVien) {
        if ( sinhVien == null ) {
            return null;
        }

        SinhVienResponse.SinhVienResponseBuilder sinhVienResponse = SinhVienResponse.builder();

        sinhVienResponse.email( sinhVienUserEmail( sinhVien ) );
        sinhVienResponse.tenLop( sinhVienLopTenLop( sinhVien ) );
        sinhVienResponse.maSV( sinhVien.getMaSinhVien() );
        if ( sinhVien.getDuDieuKien() != null ) {
            sinhVienResponse.kichHoat( sinhVien.getDuDieuKien() );
        }
        sinhVienResponse.hoTen( sinhVien.getHoTen() );
        sinhVienResponse.soDienThoai( sinhVien.getSoDienThoai() );

        return sinhVienResponse.build();
    }

    @Override
    public SinhVienSupervisedResponse toSinhVienSupervisedResponse(SinhVien sv) {
        if ( sv == null ) {
            return null;
        }

        SinhVienSupervisedResponse.SinhVienSupervisedResponseBuilder sinhVienSupervisedResponse = SinhVienSupervisedResponse.builder();

        sinhVienSupervisedResponse.maSV( sv.getMaSinhVien() );
        sinhVienSupervisedResponse.tenLop( sinhVienLopTenLop( sv ) );
        sinhVienSupervisedResponse.tenDeTai( svDeTaiTenDeTai( sv ) );
        sinhVienSupervisedResponse.cvUrl( sv.getDuongDanCv() );
        sinhVienSupervisedResponse.hoTen( sv.getHoTen() );
        sinhVienSupervisedResponse.soDienThoai( sv.getSoDienThoai() );

        return sinhVienSupervisedResponse.build();
    }

    @Override
    public SinhVienSupervisedResponse toStudentSupervisedResponse(SinhVien sv) {
        if ( sv == null ) {
            return null;
        }

        SinhVienSupervisedResponse.SinhVienSupervisedResponseBuilder sinhVienSupervisedResponse = SinhVienSupervisedResponse.builder();

        sinhVienSupervisedResponse.maSV( sv.getMaSinhVien() );
        sinhVienSupervisedResponse.tenLop( sinhVienLopTenLop( sv ) );
        sinhVienSupervisedResponse.tenDeTai( svDeTaiTenDeTai( sv ) );
        sinhVienSupervisedResponse.cvUrl( sv.getDuongDanCv() );
        sinhVienSupervisedResponse.hoTen( sv.getHoTen() );
        sinhVienSupervisedResponse.soDienThoai( sv.getSoDienThoai() );

        return sinhVienSupervisedResponse.build();
    }

    @Override
    public ApprovalSinhVienResponse toDeTaiSinhVienApprovalResponse(SinhVien sv) {
        if ( sv == null ) {
            return null;
        }

        ApprovalSinhVienResponse.ApprovalSinhVienResponseBuilder approvalSinhVienResponse = ApprovalSinhVienResponse.builder();

        approvalSinhVienResponse.maSV( sv.getMaSinhVien() );
        Long id = svDeTaiId( sv );
        if ( id != null ) {
            approvalSinhVienResponse.idDeTai( String.valueOf( id ) );
        }
        approvalSinhVienResponse.tenLop( sinhVienLopTenLop( sv ) );
        approvalSinhVienResponse.tenDeTai( svDeTaiTenDeTai( sv ) );
        approvalSinhVienResponse.trangThai( svDeTaiTrangThai( sv ) );
        approvalSinhVienResponse.tongQuanDeTaiUrl( svDeTaiNoiDungDeTaiUrl( sv ) );
        approvalSinhVienResponse.nhanXet( svDeTaiNhanXet( sv ) );
        approvalSinhVienResponse.hoTen( sv.getHoTen() );
        approvalSinhVienResponse.soDienThoai( sv.getSoDienThoai() );

        return approvalSinhVienResponse.build();
    }

    @Override
    public SinhVienInfoResponse toSinhVienInfoResponse(SinhVien sv) {
        if ( sv == null ) {
            return null;
        }

        SinhVienInfoResponse.SinhVienInfoResponseBuilder sinhVienInfoResponse = SinhVienInfoResponse.builder();

        sinhVienInfoResponse.maSV( sv.getMaSinhVien() );
        sinhVienInfoResponse.tenLop( sinhVienLopTenLop( sv ) );
        sinhVienInfoResponse.email( sinhVienUserEmail( sv ) );
        sinhVienInfoResponse.tenKhoa( svLopNganhKhoaTenKhoa( sv ) );
        sinhVienInfoResponse.tenNganh( svLopNganhTenNganh( sv ) );
        sinhVienInfoResponse.cvUrl( sv.getDuongDanCv() );
        sinhVienInfoResponse.hoTen( sv.getHoTen() );
        sinhVienInfoResponse.soDienThoai( sv.getSoDienThoai() );

        return sinhVienInfoResponse.build();
    }

    @Override
    public GetSinhVienWithoutDeTaiResponse toGetSinhVienWithoutDeTaiResponse(SinhVien sv) {
        if ( sv == null ) {
            return null;
        }

        GetSinhVienWithoutDeTaiResponse.GetSinhVienWithoutDeTaiResponseBuilder getSinhVienWithoutDeTaiResponse = GetSinhVienWithoutDeTaiResponse.builder();

        getSinhVienWithoutDeTaiResponse.maSV( sv.getMaSinhVien() );
        getSinhVienWithoutDeTaiResponse.hoTen( sv.getHoTen() );

        return getSinhVienWithoutDeTaiResponse.build();
    }

    protected User sinhVienCreationRequestToUser(SinhVienCreationRequest sinhVienCreationRequest) {
        if ( sinhVienCreationRequest == null ) {
            return null;
        }

        User.UserBuilder user = User.builder();

        user.email( sinhVienCreationRequest.getEmail() );

        user.vaiTro( com.backend.gpms.features.auth.domain.Role.SINH_VIEN );

        return user.build();
    }

    private String sinhVienUserEmail(SinhVien sinhVien) {
        User user = sinhVien.getUser();
        if ( user == null ) {
            return null;
        }
        return user.getEmail();
    }

    private String sinhVienLopTenLop(SinhVien sinhVien) {
        Lop lop = sinhVien.getLop();
        if ( lop == null ) {
            return null;
        }
        return lop.getTenLop();
    }

    private String svDeTaiTenDeTai(SinhVien sinhVien) {
        DeTai deTai = sinhVien.getDeTai();
        if ( deTai == null ) {
            return null;
        }
        return deTai.getTenDeTai();
    }

    private Long svDeTaiId(SinhVien sinhVien) {
        DeTai deTai = sinhVien.getDeTai();
        if ( deTai == null ) {
            return null;
        }
        return deTai.getId();
    }

    private TrangThaiDeTai svDeTaiTrangThai(SinhVien sinhVien) {
        DeTai deTai = sinhVien.getDeTai();
        if ( deTai == null ) {
            return null;
        }
        return deTai.getTrangThai();
    }

    private String svDeTaiNoiDungDeTaiUrl(SinhVien sinhVien) {
        DeTai deTai = sinhVien.getDeTai();
        if ( deTai == null ) {
            return null;
        }
        return deTai.getNoiDungDeTaiUrl();
    }

    private String svDeTaiNhanXet(SinhVien sinhVien) {
        DeTai deTai = sinhVien.getDeTai();
        if ( deTai == null ) {
            return null;
        }
        return deTai.getNhanXet();
    }

    private String svLopNganhKhoaTenKhoa(SinhVien sinhVien) {
        Lop lop = sinhVien.getLop();
        if ( lop == null ) {
            return null;
        }
        Nganh nganh = lop.getNganh();
        if ( nganh == null ) {
            return null;
        }
        Khoa khoa = nganh.getKhoa();
        if ( khoa == null ) {
            return null;
        }
        return khoa.getTenKhoa();
    }

    private String svLopNganhTenNganh(SinhVien sinhVien) {
        Lop lop = sinhVien.getLop();
        if ( lop == null ) {
            return null;
        }
        Nganh nganh = lop.getNganh();
        if ( nganh == null ) {
            return null;
        }
        return nganh.getTenNganh();
    }
}
