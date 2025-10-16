package com.backend.gpms.common.mapper;

import com.backend.gpms.features.auth.domain.Role;
import com.backend.gpms.features.auth.domain.User;
import com.backend.gpms.features.department.domain.BoMon;
import com.backend.gpms.features.lecturer.domain.GiangVien;
import com.backend.gpms.features.lecturer.dto.request.GiangVienCreateRequest;
import com.backend.gpms.features.lecturer.dto.response.GiangVienCreationResponse;
import com.backend.gpms.features.lecturer.dto.response.GiangVienInfoResponse;
import com.backend.gpms.features.lecturer.dto.response.GiangVienLiteResponse;
import com.backend.gpms.features.lecturer.dto.response.GiangVienResponse;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-10-16T20:53:01+0700",
    comments = "version: 1.6.3, compiler: javac, environment: Java 21.0.4 (Oracle Corporation)"
)
@Component
public class GiangVienMapperImpl implements GiangVienMapper {

    @Override
    public GiangVien toGiangVien(GiangVienCreateRequest request) {
        if ( request == null ) {
            return null;
        }

        GiangVien.GiangVienBuilder giangVien = GiangVien.builder();

        giangVien.boMon( giangVienCreateRequestToBoMon( request ) );
        giangVien.hoTen( request.getHoTen() );
        giangVien.maGiangVien( request.getMaGiangVien() );
        giangVien.soDienThoai( request.getSoDienThoai() );
        giangVien.hocHam( request.getHocHam() );
        giangVien.hocVi( request.getHocVi() );
        giangVien.quotaInstruct( request.getQuotaInstruct() );
        giangVien.ngaySinh( request.getNgaySinh() );

        return giangVien.build();
    }

    @Override
    public GiangVienCreationResponse toGiangVienCreationResponse(GiangVien entity) {
        if ( entity == null ) {
            return null;
        }

        GiangVienCreationResponse.GiangVienCreationResponseBuilder giangVienCreationResponse = GiangVienCreationResponse.builder();

        giangVienCreationResponse.maGV( entity.getMaGiangVien() );
        giangVienCreationResponse.email( entityUserEmail( entity ) );
        giangVienCreationResponse.vaiTro( mapRoleDefault( entityUserVaiTro( entity ) ) );
        giangVienCreationResponse.boMonId( map( entity.getBoMon() ) );
        giangVienCreationResponse.hoTen( entity.getHoTen() );
        giangVienCreationResponse.soDienThoai( entity.getSoDienThoai() );
        giangVienCreationResponse.hocVi( entity.getHocVi() );
        giangVienCreationResponse.hocHam( entity.getHocHam() );

        return giangVienCreationResponse.build();
    }

    @Override
    public GiangVienInfoResponse toGiangVienInfoResponse(GiangVien entity) {
        if ( entity == null ) {
            return null;
        }

        GiangVienInfoResponse.GiangVienInfoResponseBuilder giangVienInfoResponse = GiangVienInfoResponse.builder();

        giangVienInfoResponse.maGV( entity.getMaGiangVien() );
        giangVienInfoResponse.hoTen( entity.getHoTen() );
        giangVienInfoResponse.hocVi( entity.getHocVi() );
        giangVienInfoResponse.hocHam( entity.getHocHam() );

        return giangVienInfoResponse.build();
    }

    @Override
    public GiangVienLiteResponse toLite(GiangVien entity) {
        if ( entity == null ) {
            return null;
        }

        GiangVienLiteResponse.GiangVienLiteResponseBuilder giangVienLiteResponse = GiangVienLiteResponse.builder();

        giangVienLiteResponse.boMonId( entityBoMonId( entity ) );
        giangVienLiteResponse.id( entity.getId() );
        giangVienLiteResponse.hoTen( entity.getHoTen() );
        giangVienLiteResponse.quotaInstruct( entity.getQuotaInstruct() );

        return giangVienLiteResponse.build();
    }

    @Override
    public GiangVienResponse toGiangVienResponse(GiangVien entity) {
        if ( entity == null ) {
            return null;
        }

        GiangVienResponse.GiangVienResponseBuilder giangVienResponse = GiangVienResponse.builder();

        giangVienResponse.email( entityUserEmail( entity ) );
        giangVienResponse.boMonId( entityBoMonId( entity ) );
        giangVienResponse.id( entity.getId() );
        giangVienResponse.hoTen( entity.getHoTen() );
        giangVienResponse.soDienThoai( entity.getSoDienThoai() );
        giangVienResponse.hocVi( entity.getHocVi() );
        giangVienResponse.hocHam( entity.getHocHam() );

        return giangVienResponse.build();
    }

    protected BoMon giangVienCreateRequestToBoMon(GiangVienCreateRequest giangVienCreateRequest) {
        if ( giangVienCreateRequest == null ) {
            return null;
        }

        BoMon boMon = new BoMon();

        boMon.setId( giangVienCreateRequest.getIdBoMon() );

        return boMon;
    }

    private String entityUserEmail(GiangVien giangVien) {
        User user = giangVien.getUser();
        if ( user == null ) {
            return null;
        }
        return user.getEmail();
    }

    private Role entityUserVaiTro(GiangVien giangVien) {
        User user = giangVien.getUser();
        if ( user == null ) {
            return null;
        }
        return user.getVaiTro();
    }

    private Long entityBoMonId(GiangVien giangVien) {
        BoMon boMon = giangVien.getBoMon();
        if ( boMon == null ) {
            return null;
        }
        return boMon.getId();
    }
}
