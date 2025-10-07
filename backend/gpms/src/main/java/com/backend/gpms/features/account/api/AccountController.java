package com.backend.gpms.features.account.api;

import com.backend.gpms.common.util.ApiResponse;
import com.backend.gpms.features.account.application.GiangVienAccountService;
import com.backend.gpms.features.account.application.SinhVienAccountService;
import com.backend.gpms.features.account.dto.response.CreatedAccountResponse;
import com.backend.gpms.features.lecturer.dto.request.GiangVienCreateRequest;
import com.backend.gpms.features.student.dto.request.SinhVienCreateRequest;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Account - GiangVien - SinhVien")
@RestController
@RequestMapping("/api/account")
@RequiredArgsConstructor
public class AccountController {

    private final GiangVienAccountService giangVienService;
    private final SinhVienAccountService  sinhVienService;

    @PreAuthorize("hasAnyRole('QUAN_TRI_VIEN','TRO_LY_KHOA')")
    @PostMapping("/giang-vien")
    public ApiResponse<CreatedAccountResponse> createLecturer(
            @RequestBody @Valid GiangVienCreateRequest req) {
        return giangVienService.register(req);
    }

    @PreAuthorize("hasAnyRole('QUAN_TRI_VIEN','TRO_LY_KHOA')")
    @PostMapping("/sinh-vien")
    public ApiResponse<CreatedAccountResponse> createStudent(
            @RequestBody @Valid SinhVienCreateRequest req) {
        return sinhVienService.register(req);
    }
}
