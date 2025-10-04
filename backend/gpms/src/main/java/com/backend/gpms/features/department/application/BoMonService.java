package com.backend.gpms.features.department.application;

import com.backend.gpms.common.exception.ApplicationException;
import com.backend.gpms.common.exception.ErrorCode;
import com.backend.gpms.common.mapper.BoMonMapper;
import com.backend.gpms.common.mapper.GiangVienMapper;
import com.backend.gpms.features.auth.domain.Role;
import com.backend.gpms.features.department.domain.BoMon;
import com.backend.gpms.features.department.domain.Khoa;
import com.backend.gpms.features.department.dto.request.BoMonRequest;
import com.backend.gpms.features.department.dto.request.TruongBoMonCreationRequest;
import com.backend.gpms.features.department.dto.response.BoMonResponse;
import com.backend.gpms.features.department.dto.response.BoMonWithTruongBoMonResponse;
import com.backend.gpms.features.department.dto.response.TruongBoMonCreationResponse;
import com.backend.gpms.features.department.infra.BoMonRepository;
import com.backend.gpms.features.department.infra.KhoaRepository;
import com.backend.gpms.features.lecturer.domain.GiangVien;
import com.backend.gpms.features.lecturer.infra.GiangVienRepository;
import jakarta.transaction.Transactional;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
@RequiredArgsConstructor
@Transactional
public class BoMonService{

    BoMonRepository boMonRepository;
    BoMonMapper boMonMapper;
    KhoaRepository khoaRepository;
    private final GiangVienRepository giangVienRepository;
    GiangVienMapper giangVienMapper;


    public BoMonResponse createBoMon(BoMonRequest boMonRequest) {
        if(boMonRepository.existsByTenBoMonIgnoreCase(boMonRequest.getTenBoMon())) {
            throw new ApplicationException(ErrorCode.DUPLICATED_BO_MON);
        }
        return boMonMapper.toBoMonResponse(boMonRepository.save(boMonMapper.toBoMon(boMonRequest)));
    }


    public BoMonResponse updateBoMon(BoMonRequest boMonRequest, Long boMonId) {
        if(boMonRepository.existsByTenBoMonIgnoreCase(boMonRequest.getTenBoMon())) {
            throw new ApplicationException(ErrorCode.DUPLICATED_BO_MON);
        }
        BoMon boMon = boMonRepository.findById(boMonId)
                .orElseThrow(() -> new ApplicationException(ErrorCode.BO_MON_NOT_FOUND));
        boMon.setTenBoMon(boMonRequest.getTenBoMon());
        Khoa khoa = khoaRepository.findById(boMonRequest.getKhoaId())
                .orElseThrow(() -> new ApplicationException(ErrorCode.KHOA_NOT_FOUND));
        boMon.setKhoa(khoa);
        return boMonMapper.toBoMonResponse(boMonRepository.save(boMon));
    }



    public void deleteBoMon(Long boMonId) {
        boMonRepository.deleteById(boMonId);
    }


    public Page<BoMonResponse> getAllBoMon(Pageable pageable) {
        Page<BoMon> boMonPage = boMonRepository.findAll(pageable);
        return boMonPage.map(boMonMapper::toBoMonResponse);
    }


    public TruongBoMonCreationResponse createTruongBoMon(TruongBoMonCreationRequest truongBoMonCreationRequest) {

        GiangVien truongBoMon = giangVienRepository.findById(truongBoMonCreationRequest.getGiangVienId())
                .orElseThrow(() -> new ApplicationException(ErrorCode.GIANG_VIEN_NOT_FOUND));
        BoMon boMon = boMonRepository.findById(truongBoMonCreationRequest.getBoMonId())
                .orElseThrow(() -> new ApplicationException(ErrorCode.BO_MON_NOT_FOUND));
        if(truongBoMon.getBoMonQuanLy() != null) {
            throw new ApplicationException(ErrorCode.TRUONG_BO_MON_ALREADY);
        }
        if(truongBoMon.getBoMon() != boMon) {
            throw new ApplicationException(ErrorCode.NOT_IN_BO_MON);
        }
        if(boMon.getTruongBoMon() != null) {
            GiangVien currentTruongBoMon = boMon.getTruongBoMon();
            currentTruongBoMon.getUser().setVaiTro(Role.GIANG_VIEN);
            currentTruongBoMon.setBoMonQuanLy(null);
            giangVienRepository.save(currentTruongBoMon);
        }
        truongBoMon.setBoMonQuanLy(boMon);
        truongBoMon.getUser().setVaiTro(Role.TRUONG_BO_MON);
        boMon.setTruongBoMon(truongBoMon);
        giangVienRepository.save(truongBoMon);
        return boMonMapper.toTruongBoMonCreationResponse(boMonRepository.save(boMon));

    }


    public Page<BoMonWithTruongBoMonResponse> findAllWithTruongBoMon(Pageable pageable) {
        return boMonRepository.findAll(pageable)
                .map(boMonMapper::toWithTruongBoMon);
    }
}
