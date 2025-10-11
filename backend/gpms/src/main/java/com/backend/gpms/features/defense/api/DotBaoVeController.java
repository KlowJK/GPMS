package com.backend.gpms.features.defense.api;


import com.backend.gpms.common.util.ApiResponse;
import com.backend.gpms.features.defense.application.DotBaoVeService;
import com.backend.gpms.features.defense.application.ThoiGianThucHienService;
import com.backend.gpms.features.defense.dto.request.AddSinhVienToDotBaoVeRequest;
import com.backend.gpms.features.defense.dto.request.DotBaoVeRequest;
import com.backend.gpms.features.defense.dto.request.ThoiGianThucHienRequest;
import com.backend.gpms.features.defense.dto.response.AddSinhVienToDotBaoVeResponse;
import com.backend.gpms.features.defense.dto.response.DotBaoVeResponse;
import com.backend.gpms.features.defense.dto.response.ThoiGianThucHienResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springdoc.core.annotations.ParameterObject;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.MediaType;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

@Tag(name = "DotBaoVe")
@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
public class DotBaoVeController {

    ThoiGianThucHienService thoiGianThucHienService;
    DotBaoVeService dotBaoVeService;


    @Operation(summary = "Tạo mới thời gian thực hiện của đợt bảo vệ - Role Trợ lý khoa")
    @PreAuthorize("hasAuthority('ROLE_TRO_LY_KHOA')")
    @PostMapping("/thoi-gian-thuc-hien")
    public ApiResponse<ThoiGianThucHienResponse> createThoiGianThucHien(@RequestBody ThoiGianThucHienRequest thoiGianThucHienRequest) {

        return ApiResponse.success(thoiGianThucHienService.createThoiGianThucHien(thoiGianThucHienRequest));

    }

    @Operation(summary = "Cập nhật công việc, thời gian thực hiện của đợt bảo vệ - Role Trợ lý khoa")
    @PreAuthorize("hasAuthority('ROLE_TRO_LY_KHOA')")
    @PutMapping("/thoi-gian-thuc-hien/{thoiGianThucHienId}")
    public ApiResponse<ThoiGianThucHienResponse> updateThoiGianThucHien(

            @PathVariable Long thoiGianThucHienId,
            @RequestBody ThoiGianThucHienRequest thoiGianThucHienRequest
            ) {

        return ApiResponse.success(thoiGianThucHienService.updateThoiGianThucHien(thoiGianThucHienRequest, thoiGianThucHienId));

    }
    @Operation(summary = "Lấy danh sách thời gian thực hiện của đợt bảo vệ")
    @GetMapping("/thoi-gian-thuc-hien")
    public ApiResponse<Page<ThoiGianThucHienResponse>> getAllThoiGianThucHien(
            @ParameterObject
            @PageableDefault(
                    page = 0,
                    size = 10,
                    sort = "dotBaoVe.ngayBatDau",
                    direction = Sort.Direction.DESC) Pageable pageable
    ) {

        return ApiResponse.success(thoiGianThucHienService.getAllThoiGianThucHien(pageable));

    }

    @Operation(summary = "Tạo mới đợt bảo vệ - Role Trợ lý khoa")
    @PreAuthorize("hasAuthority('ROLE_TRO_LY_KHOA')")
    @PostMapping("/dot-bao-ve")
    public ApiResponse<DotBaoVeResponse> createDotBaoVe(@RequestBody DotBaoVeRequest dotBaoVeRequest) {

        return ApiResponse.success(dotBaoVeService.createDotBaoVe(dotBaoVeRequest));

    }

    @Operation(summary = "Lấy danh sách đợt bảo vệ - Role Trưởng bộ môn, Trợ lý khoa, Giảng viên")
    @PreAuthorize("hasAnyAuthority('ROLE_TRUONG_BO_MON',  'ROLE_TRO_LY_KHOA', 'ROLE_GIANG_VIEN')")
    @GetMapping("/dot-bao-ve")
    public ApiResponse<Page<DotBaoVeResponse>> findAllDotBaoVe(
            @ParameterObject
            @PageableDefault(
                    page = 0,
                    size = 10,
                    sort = "updatedAt",
                    direction = Sort.Direction.DESC) Pageable pageable
    ) {
        return ApiResponse.success(dotBaoVeService.findAllDotBaoVe(pageable));
    }

    @Operation(summary = "Cập nhật đợt bảo vệ - Role Trợ lý khoa")
    @PreAuthorize("hasAuthority('ROLE_TRO_LY_KHOA')")
    @PutMapping("/dot-bao-ve/{dotBaoVeId}")
    public ApiResponse<DotBaoVeResponse> updateDotBaoVe(@RequestBody DotBaoVeRequest request, @PathVariable("dotBaoVeId") Long dotBaoVeId) {

        return ApiResponse.success(dotBaoVeService.updateDotBaoVe(request, dotBaoVeId));

    }

    @Operation(summary = "Xóa đợt bảo vệ - Role Trợ lý khoa")
    @PreAuthorize("hasAuthority('ROLE_TRO_LY_KHOA')")
    @DeleteMapping("/dot-bao-ve/{dotBaoVeId}")
    public ApiResponse<String> deleteDotBaoVe(@PathVariable("dotBaoVeId") Long dotBaoVeId) {

        dotBaoVeService.deleteDotBaoVe(dotBaoVeId);
        return ApiResponse.success("Delete dot bao ve successfully");

    }

    @Operation(summary = "Import sinh viên vào đợt bảo vệ từ file Excel, excel 2 cột: 1 mã sv, 1 tên đề tài - Role Trợ lý khoa")
    @PreAuthorize("hasAuthority('ROLE_TRO_LY_KHOA')")
    @PostMapping(value = "/dot-bao-ve/import-sinh-vien", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ApiResponse<AddSinhVienToDotBaoVeResponse> importSinhVien(
            @RequestParam("dataFile") MultipartFile file,
            @RequestParam("namHoc") String namHoc,
            @RequestParam("hocKi") String hocKi
    ) throws IOException {
        var request = AddSinhVienToDotBaoVeRequest.builder()
                .dataFile(file)
                .namHoc(namHoc)
                .hocKi(hocKi)
                .build();
        return ApiResponse.success(dotBaoVeService.addSinhVienToDotBaoVe(request));
    }
}