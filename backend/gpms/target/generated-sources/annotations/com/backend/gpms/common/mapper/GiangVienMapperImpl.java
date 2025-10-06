package com.backend.gpms.common.mapper;

import com.backend.gpms.features.lecturer.domain.GiangVien;
import com.backend.gpms.features.lecturer.dto.request.GiangVienCreationRequest;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-10-06T20:41:18+0700",
    comments = "version: 1.6.3, compiler: javac, environment: Java 21.0.4 (Oracle Corporation)"
)
@Component
public class GiangVienMapperImpl implements GiangVienMapper {

    @Override
    public GiangVien toGiangVien(GiangVienCreationRequest request) {
        if ( request == null ) {
            return null;
        }

        GiangVien.GiangVienBuilder giangVien = GiangVien.builder();

        giangVien.hoTen( request.getHoTen() );
        giangVien.maGiangVien( request.getMaGiangVien() );
        giangVien.soDienThoai( request.getSoDienThoai() );
        giangVien.hocHam( request.getHocHam() );
        giangVien.hocVi( request.getHocVi() );
        giangVien.quotaInstruct( request.getQuotaInstruct() );
        giangVien.ngaySinh( request.getNgaySinh() );

        return giangVien.build();
    }
}
