package com.backend.gpms.common.mapper;

import com.backend.gpms.features.student.domain.SinhVien;
import com.backend.gpms.features.student.dto.request.SinhVienCreateRequest;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-10-03T00:32:58+0700",
    comments = "version: 1.6.3, compiler: javac, environment: Java 21.0.8 (Microsoft)"
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
