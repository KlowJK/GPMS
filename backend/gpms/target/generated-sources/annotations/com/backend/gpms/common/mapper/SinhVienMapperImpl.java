package com.backend.gpms.common.mapper;

import com.backend.gpms.features.student.domain.SinhVien;
import com.backend.gpms.features.student.dto.request.SinhVienCreateRequest;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-10-06T01:00:11+0700",
    comments = "version: 1.6.3, compiler: javac, environment: Java 21.0.4 (Oracle Corporation)"
)
@Component
public class SinhVienMapperImpl implements SinhVienMapper {

    @Override
    public SinhVien toSinhVien(SinhVienCreateRequest req) {
        if ( req == null ) {
            return null;
        }

        SinhVien sinhVien = new SinhVien();

        sinhVien.setHoTen( req.getHoTen() );
        sinhVien.setMaSinhVien( req.getMaSinhVien() );
        sinhVien.setSoDienThoai( req.getSoDienThoai() );
        sinhVien.setNgaySinh( req.getNgaySinh() );
        sinhVien.setDiaChi( req.getDiaChi() );

        return sinhVien;
    }
}
