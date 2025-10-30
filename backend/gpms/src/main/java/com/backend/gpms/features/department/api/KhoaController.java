package com.backend.gpms.features.department.api;

import com.backend.gpms.common.util.ApiResponse;
import com.backend.gpms.features.account.dto.request.TroLyKhoaRequest;
import com.backend.gpms.features.account.dto.response.TroLyKhoaResponse;
import com.backend.gpms.features.department.application.KhoaService;
import com.backend.gpms.features.account.application.TroLyKhoaService;
import com.backend.gpms.features.department.dto.request.*;
import com.backend.gpms.features.department.dto.response.*;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Khoa")
@RestController
@RequestMapping(
        value = "/api/khoa"
)
@RequiredArgsConstructor
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
public class KhoaController {

    KhoaService khoaService;
    TroLyKhoaService troLyKhoaService;

    @GetMapping
    public ApiResponse<List<KhoaResponse>> getKhoa() {
        return ApiResponse.success(khoaService.getAllKhoa());
    }

    @PostMapping
    public ApiResponse<KhoaResponse> createKhoa(@Valid @RequestBody KhoaRequest khoaRequest) {
        return ApiResponse.success(khoaService.createKhoa(khoaRequest));
    }

    @PutMapping("/{khoaId}")
    public ApiResponse<KhoaResponse> updateKhoa(@PathVariable Long khoaId,
                                                @Valid @RequestBody KhoaRequest khoaRequest) {
        return ApiResponse.success(khoaService.updateKhoa(khoaRequest, khoaId));
    }

    @DeleteMapping("/{khoaId}")
    public ApiResponse<String> deleteKhoa(@PathVariable Long khoaId) {
        khoaService.deleteKhoa(khoaId);
        return ApiResponse.success("Delete khoa successfully");
    }

    @Operation(summary = "Lấy danh sách trợ lý khoa - Role quản trị viên")
    @PreAuthorize("hasAuthority('ROLE_QUAN_TRI_VIEN')")
    @GetMapping("/tro-ly-khoa")
    public ApiResponse<List<TroLyKhoaResponse>> getTroLyKhoa() {
        return ApiResponse.success(troLyKhoaService.getAllTroLyKhoa());
    }
    @Operation(summary = "Thêm trợ lý khoa - Role quản trị viên")
    @PreAuthorize("hasAuthority('ROLE_QUAN_TRI_VIEN')")
    @PostMapping("/tro-ly-khoa")
    public ApiResponse<TroLyKhoaResponse> createTroLyKhoa(
                                                @Valid @RequestBody TroLyKhoaRequest troLyKhoaRequest) {
        return ApiResponse.success(troLyKhoaService.createTroLyKhoa(troLyKhoaRequest));
    }

    @Operation(summary = "Cập nhật trợ lý khoa - Role quản trị viên")
    @PreAuthorize("hasAuthority('ROLE_QUAN_TRI_VIEN')")
    @PutMapping("/tro-ly-khoa/{id}")
    public ApiResponse<TroLyKhoaResponse> createTroLyKhoa(@PathVariable Long id,
            @Valid @RequestBody TroLyKhoaRequest troLyKhoaRequest) {
        return ApiResponse.success(troLyKhoaService.updateTroLyKhoa(id,troLyKhoaRequest));
    }

    @Operation(summary = "Xoá trợ lý khoa - Role quản trị viên")
    @PreAuthorize("hasAuthority('ROLE_QUAN_TRI_VIEN')")
    @DeleteMapping("/tro-ly-khoa/{id}")
    public ApiResponse<String> deleteTroLyKhoa(@PathVariable Long id) {
        troLyKhoaService.deleteTroLyKhoa(id);
        return ApiResponse.success("Delete tro ly khoa successfully");
    }

}
