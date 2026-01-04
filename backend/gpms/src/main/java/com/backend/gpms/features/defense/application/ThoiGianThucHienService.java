package com.backend.gpms.features.defense.application;

import com.backend.gpms.common.exception.ApplicationException;
import com.backend.gpms.common.exception.ErrorCode;
import com.backend.gpms.common.mapper.ThoiGianThucHienMapper;
import com.backend.gpms.features.defense.domain.DotBaoVe;
import com.backend.gpms.features.defense.domain.ThoiGianThucHien;
import com.backend.gpms.features.defense.dto.request.ThoiGianThucHienRequest;
import com.backend.gpms.features.defense.dto.response.ThoiGianThucHienResponse;
import com.backend.gpms.features.defense.infra.DotBaoVeRepository;
import com.backend.gpms.features.defense.infra.ThoiGianThucHienRepository;
import jakarta.transaction.Transactional;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

@Service
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@RequiredArgsConstructor
@Transactional
public class ThoiGianThucHienService {

    ThoiGianThucHienRepository thoiGianThucHienRepository;
    DotBaoVeRepository dotBaoVeRepository;
    private final ThoiGianThucHienMapper thoiGianThucHienMapper;


    public ThoiGianThucHienResponse createThoiGianThucHien(ThoiGianThucHienRequest thoiGianThucHienRequest) {
        DotBaoVe dotBaoVe = validateThoiGianThucHien(thoiGianThucHienRequest);
        var entity = thoiGianThucHienMapper.toThoiGianThucHien(thoiGianThucHienRequest);
        entity.setDotBaoVe(dotBaoVe);
        entity = thoiGianThucHienRepository.save(entity);

        return thoiGianThucHienMapper.toThoiGianThucHienResponse(entity);
    }


    public ThoiGianThucHienResponse updateThoiGianThucHien(ThoiGianThucHienRequest thoiGianThucHienRequest, Long thoiGianThucHienId) {
        var thoiGianThucHien = thoiGianThucHienRepository.findById(thoiGianThucHienId)
                .orElseThrow(() -> new ApplicationException(ErrorCode.THOI_GIAN_THUC_HIEN_NOT_FOUND));

        DotBaoVe dotBaoVe = dotBaoVeRepository.findById(thoiGianThucHienRequest.getDotBaoVeId())
                .orElseThrow(() -> new ApplicationException(ErrorCode.DOT_BAO_VE_NOT_FOUND));
        if(thoiGianThucHienRequest.getThoiGianBatDau().isAfter(thoiGianThucHienRequest.getThoiGianKetThuc())) {
            throw new ApplicationException(ErrorCode.INVALID_TIME_RANGE);
        }
        if (thoiGianThucHienRequest.getThoiGianBatDau().isBefore(dotBaoVe.getNgayBatDau()) ||
                thoiGianThucHienRequest.getThoiGianKetThuc().isAfter(dotBaoVe.getNgayKetThuc())) {
            throw new ApplicationException(ErrorCode.INVALID_TIME_RANGE);
        }
        if (thoiGianThucHien.getCongViec() != thoiGianThucHienRequest.getCongViec()
                && thoiGianThucHienRepository.existsByDotBaoVeAndCongViec
                (dotBaoVe, thoiGianThucHienRequest.getCongViec())) {
            throw new ApplicationException(ErrorCode.CONG_VIEC_EXISTED);
        }

        thoiGianThucHienMapper.updateThoiGianThucHienFromDto(thoiGianThucHienRequest, thoiGianThucHien);
        return thoiGianThucHienMapper.toThoiGianThucHienResponse(thoiGianThucHienRepository.save(thoiGianThucHien));
    }


    public Page<ThoiGianThucHienResponse> getAllThoiGianThucHien(Pageable pageable) {
        Page<ThoiGianThucHien> thoiGianThucHienPage = thoiGianThucHienRepository.findAll(pageable);
        return thoiGianThucHienPage.map(thoiGianThucHienMapper::toThoiGianThucHienResponse);
    }

    private DotBaoVe validateThoiGianThucHien(ThoiGianThucHienRequest thoiGianThucHienRequest) {

        DotBaoVe dotBaoVe = dotBaoVeRepository.findById(thoiGianThucHienRequest.getDotBaoVeId())
                .orElseThrow(() -> new ApplicationException(ErrorCode.DOT_BAO_VE_NOT_FOUND));
        if(thoiGianThucHienRequest.getThoiGianBatDau().isAfter(thoiGianThucHienRequest.getThoiGianKetThuc())) {
            throw new ApplicationException(ErrorCode.INVALID_TIME_RANGE);
        }
        if (thoiGianThucHienRequest.getThoiGianBatDau().isBefore(dotBaoVe.getNgayBatDau()) ||
                thoiGianThucHienRequest.getThoiGianKetThuc().isAfter(dotBaoVe.getNgayKetThuc())) {
            throw new ApplicationException(ErrorCode.INVALID_TIME_RANGE);
        }
        if (thoiGianThucHienRepository.existsByDotBaoVeAndCongViec(
                dotBaoVe, thoiGianThucHienRequest.getCongViec())) {
            throw new ApplicationException(ErrorCode.CONG_VIEC_EXISTED);
        }
        return dotBaoVe;
    }
}
