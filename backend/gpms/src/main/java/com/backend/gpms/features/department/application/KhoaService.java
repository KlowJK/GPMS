package com.backend.gpms.features.department.application;

import com.backend.gpms.common.exception.ApplicationException;
import com.backend.gpms.common.exception.ErrorCode;
import com.backend.gpms.common.mapper.KhoaMapper;
import com.backend.gpms.features.department.domain.Khoa;
import com.backend.gpms.features.department.dto.request.KhoaRequest;
import com.backend.gpms.features.department.dto.response.KhoaResponse;
import com.backend.gpms.features.department.infra.KhoaRepository;
import jakarta.transaction.Transactional;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
@RequiredArgsConstructor
@Transactional
public class KhoaService {

    KhoaRepository khoaRepository;
    KhoaMapper khoaMapper;


    public KhoaResponse createKhoa(KhoaRequest khoaRequest) {

        if (khoaRepository.existsByTenKhoaIgnoreCase(khoaRequest.getTenKhoa())) {
            throw new ApplicationException(ErrorCode.DUPLICATED_KHOA);
        }
        return khoaMapper.toKhoaResponse(khoaRepository.save(khoaMapper.toKhoa(khoaRequest)));

    }

    public KhoaResponse updateKhoa(KhoaRequest khoaRequest, Long khoaId) {
        if (khoaRepository.existsByTenKhoaIgnoreCase(khoaRequest.getTenKhoa())) {
            throw new ApplicationException(ErrorCode.DUPLICATED_KHOA);
        }
        Khoa khoa = khoaRepository.findById(khoaId)
                .orElseThrow(() -> new ApplicationException(ErrorCode.KHOA_NOT_FOUND));
        khoa.setTenKhoa(khoaRequest.getTenKhoa());
        return khoaMapper.toKhoaResponse(khoaRepository.save(khoa));
    }


    public void deleteKhoa(Long khoaId) {
        khoaRepository.deleteById(khoaId);
    }


    public List<KhoaResponse> getAllKhoa() {
        return khoaRepository.findAll().stream().map(khoaMapper::toKhoaResponse).collect(Collectors.toList());
    }
}

