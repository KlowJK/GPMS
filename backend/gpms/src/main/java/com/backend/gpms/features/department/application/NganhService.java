package com.backend.gpms.features.department.application;

import com.backend.gpms.common.exception.ApplicationException;
import com.backend.gpms.common.exception.ErrorCode;
import com.backend.gpms.common.mapper.NganhMapper;
import com.backend.gpms.features.department.domain.Khoa;
import com.backend.gpms.features.department.domain.Nganh;
import com.backend.gpms.features.department.dto.request.NganhRequest;
import com.backend.gpms.features.department.dto.response.NganhResponse;
import com.backend.gpms.features.department.infra.KhoaRepository;
import com.backend.gpms.features.department.infra.LopRepository;
import com.backend.gpms.features.department.infra.NganhRepository;
import jakarta.transaction.Transactional;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;


@Service
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
@RequiredArgsConstructor
@Transactional
public class NganhService {

    NganhRepository nganhRepository;
    NganhMapper nganhMapper;
    KhoaRepository khoaRepository;
    LopRepository lopRepository;

    public NganhResponse createNganh(NganhRequest nganhRequest) {
        if(nganhRepository.existsByTenNganhIgnoreCase(nganhRequest.getTenNganh())) {
            throw new ApplicationException(ErrorCode.DUPLICATED_NGANH);
        }
        if(nganhRepository.existsByMaNganhIgnoreCase(nganhRequest.getMaNganh())) {
            throw new ApplicationException(ErrorCode.DUPLICATED_MA_NGANH);
        }
        return nganhMapper.toNganhResponse(nganhRepository.save(nganhMapper.toNganh(nganhRequest)));
    }


    public NganhResponse updateNganh(NganhRequest nganhRequest, Long nganhId) {
        Nganh nganh = nganhRepository.findById(nganhId)
                .orElseThrow(() -> new ApplicationException(ErrorCode.NGANH_NOT_FOUND));

        // Kiểm tra trùng TÊN NGÀNH: chỉ lỗi nếu có ngành khác có cùng tên
        if (!nganh.getTenNganh().equalsIgnoreCase(nganhRequest.getTenNganh())) {
            if (nganhRepository.existsByTenNganhIgnoreCase(nganhRequest.getTenNganh())) {
                throw new ApplicationException(ErrorCode.DUPLICATED_NGANH);
            }
        }

        // Kiểm tra trùng MÃ NGÀNH: chỉ lỗi nếu có ngành khác có cùng mã
        if (!nganh.getMaNganh().equalsIgnoreCase(nganhRequest.getMaNganh())) {
            if (nganhRepository.existsByMaNganhIgnoreCase(nganhRequest.getMaNganh())) {
                throw new ApplicationException(ErrorCode.DUPLICATED_MA_NGANH);
            }
        }

        // Cập nhật thông tin
        nganh.setTenNganh(nganhRequest.getTenNganh());
        nganh.setMaNganh(nganhRequest.getMaNganh());

        Khoa khoa = khoaRepository.findById(nganhRequest.getKhoaId())
                .orElseThrow(() -> new ApplicationException(ErrorCode.KHOA_NOT_FOUND));
        nganh.setKhoa(khoa);

        return nganhMapper.toNganhResponse(nganhRepository.save(nganh));
    }

    public void deleteNganh(Long nganhId) {
        if (lopRepository.existsByNganhId(nganhId)) {
            throw new ApplicationException(ErrorCode.NGANH_HAS_LOP_CANNOT_DELETE);
        }
        nganhRepository.deleteById(nganhId);
    }


    public Page<NganhResponse> getAllNganh(Pageable pageable) {
        Page<Nganh> nganhPage = nganhRepository.findAll(pageable);
        return nganhPage.map(nganhMapper::toNganhResponse);
    }
}
