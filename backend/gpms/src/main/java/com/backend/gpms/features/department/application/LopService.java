package com.backend.gpms.features.department.application;

import com.backend.gpms.common.exception.ApplicationException;
import com.backend.gpms.common.exception.ErrorCode;
import com.backend.gpms.common.mapper.LopMapper;
import com.backend.gpms.features.department.domain.Lop;
import com.backend.gpms.features.department.domain.Nganh;
import com.backend.gpms.features.department.dto.request.LopRequest;
import com.backend.gpms.features.department.dto.response.LopResponse;
import com.backend.gpms.features.department.infra.LopRepository;
import com.backend.gpms.features.department.infra.NganhRepository;
import jakarta.transaction.Transactional;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

@Service
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
@RequiredArgsConstructor
@Transactional
public class LopService {

    LopRepository lopRepository;
    LopMapper lopMapper;
    NganhRepository nganhRepository;

    public LopResponse createLop(LopRequest lopRequest) {
        if(lopRepository.existsByTenLopIgnoreCase(lopRequest.getTenLop())) {
            throw new ApplicationException(ErrorCode.DUPLICATED_LOP);
        }
        return lopMapper.toLopResponse(lopRepository.save(lopMapper.toLop(lopRequest)));
    }

    public LopResponse updateLop(LopRequest lopRequest, Long lopId) {
        if(lopRepository.existsByTenLopIgnoreCase(lopRequest.getTenLop())) {
            throw new ApplicationException(ErrorCode.DUPLICATED_LOP);
        }
        Lop lop = lopRepository.findById(lopId)
                .orElseThrow(() -> new ApplicationException(ErrorCode.LOP_NOT_FOUND));
        lop.setTenLop(lopRequest.getTenLop());
        Nganh nganh = nganhRepository.findById(lopRequest.getNganhId())
                .orElseThrow(() -> new ApplicationException(ErrorCode.NGANH_NOT_FOUND));
        lop.setNganh(nganh);
        return lopMapper.toLopResponse(lopRepository.save(lopMapper.toLop(lopRequest)));
    }

    public void deleteLop(Long lopId) {
        lopRepository.deleteById(lopId);
    }

    public Page<LopResponse> getAllLop(Pageable pageable) {
        Page<Lop> lopPage = lopRepository.findAll(pageable);
        return lopPage.map(lopMapper::toLopResponse);
    }

}

