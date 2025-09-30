package com.backend.gpms.features.account.api;

import com.backend.gpms.features.account.application.GiangVienAccountService;
import com.backend.gpms.features.account.application.SinhVienAccountService;
import com.backend.gpms.features.account.dto.request.GiangVienAccountRequest;
import com.backend.gpms.features.account.dto.request.SinhVienAccountRequest;
import com.backend.gpms.features.account.dto.response.CreatedAccountResponse;

import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
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
    public ResponseEntity<CreatedAccountResponse> createLecturer(
            @RequestBody @Valid GiangVienAccountRequest req) {
        return ResponseEntity.ok(giangVienService.register(req));
    }

    @PreAuthorize("hasAnyRole('QUAN_TRI_VIEN','TRO_LY_KHOA')")
    @PostMapping("/sinh-vien")
    public ResponseEntity<CreatedAccountResponse> createStudent(
            @RequestBody @Valid SinhVienAccountRequest req) {
        return ResponseEntity.ok(sinhVienService.register(req));
    }
}
