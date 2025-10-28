package com.backend.gpms.features.department.application;


import com.backend.gpms.common.exception.ApplicationException;
import com.backend.gpms.common.exception.ErrorCode;
import com.backend.gpms.common.mapper.TroLyKhoaMapper;
import com.backend.gpms.features.auth.domain.Role;
import com.backend.gpms.features.auth.domain.User;
import com.backend.gpms.features.auth.infra.UserRepository;
import com.backend.gpms.features.department.domain.TroLyKhoa;
import com.backend.gpms.features.department.dto.request.TroLyKhoaRequest;
import com.backend.gpms.features.department.dto.response.TroLyKhoaResponse;
import com.backend.gpms.features.department.infra.TroLyKhoaRepository;
import jakarta.transaction.Transactional;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;

import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
@RequiredArgsConstructor
@Transactional
public class TroLyKhoaService {

     TroLyKhoaMapper troLyKhoaMapper;
     TroLyKhoaRepository trolykhoaRepository;
     UserRepository taiKhoanRepository;
     PasswordEncoder passwordEncoder;

    public List<TroLyKhoaResponse> getAllTroLyKhoa() {
        List<TroLyKhoa> troLyKhoaPage =  trolykhoaRepository.findAll();
        return troLyKhoaPage.stream().map(troLyKhoaMapper::toTroLyKhoaResponse).collect(Collectors.toList());
    }


    public TroLyKhoaResponse createTroLyKhoa(TroLyKhoaRequest troLyKhoaRequest) {

        if(taiKhoanRepository.existsByEmail((troLyKhoaRequest.getEmail()))) {
            throw new ApplicationException(ErrorCode.EMAIL_EXISTED);
        }
        var auth = SecurityContextHolder.getContext().getAuthentication();
        User taiKhoan = User.builder()
                .email(troLyKhoaRequest.getEmail())
                .matKhau(passwordEncoder.encode(troLyKhoaRequest.getMatKhau()))
                .vaiTro(Role.TRO_LY_KHOA)
                .trangThaiKichHoat(true)
                .build();
        TroLyKhoa troLyKhoa = TroLyKhoa.builder()
                .hoTen(troLyKhoaRequest.getHoTen())
                .soDienThoai(troLyKhoaRequest.getSoDienThoai())
                .diaChi(troLyKhoaRequest.getDiaChi())
                .user(taiKhoan)
                .build();

        taiKhoanRepository.save(taiKhoan);
        return troLyKhoaMapper.toTroLyKhoaResponse(trolykhoaRepository.save(troLyKhoa));
    }

    public TroLyKhoaResponse updateTroLyKhoa(Long id,TroLyKhoaRequest troLyKhoaRequest) {

        TroLyKhoa troLyKhoa = trolykhoaRepository.findById( id)
                .orElseThrow(() -> new ApplicationException(ErrorCode.TRO_LY_KHOA_NOT_FOUND));

        User taiKhoan = taiKhoanRepository.findById(troLyKhoa.getUser().getId())
                .orElseThrow(() -> new ApplicationException(ErrorCode.USER_NOT_FOUND));



        if (troLyKhoaRequest.getMatKhau() != null && !troLyKhoaRequest.getMatKhau().isBlank()) {
            taiKhoan.setMatKhau(passwordEncoder.encode(troLyKhoaRequest.getMatKhau()));
        }

        troLyKhoa.setHoTen(troLyKhoaRequest.getHoTen());
        troLyKhoa.setSoDienThoai(troLyKhoaRequest.getSoDienThoai());
        troLyKhoa.setDiaChi(troLyKhoaRequest.getDiaChi());

        taiKhoanRepository.save(taiKhoan);
        return troLyKhoaMapper.toTroLyKhoaResponse(trolykhoaRepository.save(troLyKhoa));
    }

    // java
    public void deleteTroLyKhoa(Long id) {

        TroLyKhoa troLyKhoa = trolykhoaRepository.findById(id)
            .orElseThrow(() -> new ApplicationException(ErrorCode.TRO_LY_KHOA_NOT_FOUND));

        User taiKhoan = taiKhoanRepository.findById(troLyKhoa.getUser().getId())
                .orElseThrow(() -> new ApplicationException(ErrorCode.USER_NOT_FOUND));

        trolykhoaRepository.delete(troLyKhoa);
        taiKhoanRepository.delete(taiKhoan);
    }

}
