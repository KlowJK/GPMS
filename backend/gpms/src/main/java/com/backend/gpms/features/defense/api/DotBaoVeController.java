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
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.MediaType;
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


    @PostMapping("/thoi-gian-thuc-hien")
    public ApiResponse<ThoiGianThucHienResponse> createThoiGianThucHien(@RequestBody ThoiGianThucHienRequest thoiGianThucHienRequest) {

        return ApiResponse.<ThoiGianThucHienResponse>builder()
                .result(thoiGianThucHienService.createThoiGianThucHien(thoiGianThucHienRequest))
                .build();

    }

    @PutMapping("/thoi-gian-thuc-hien/{thoiGianThucHienId}")
    public ApiResponse<ThoiGianThucHienResponse> updateThoiGianThucHien(
            @RequestBody ThoiGianThucHienRequest thoiGianThucHienRequest,
            @PathVariable Long thoiGianThucHienId) {

        return ApiResponse.<ThoiGianThucHienResponse>builder()
                .result(thoiGianThucHienService.updateThoiGianThucHien(thoiGianThucHienRequest, thoiGianThucHienId))
                .build();

    }

    @GetMapping("/thoi-gian-thuc-hien")
    public ApiResponse<Page<ThoiGianThucHienResponse>> getAllThoiGianThucHien(
            @PageableDefault(
                    page = 0,
                    size = 10,
                    sort = "dotBaoVe.thoiGianBatDau",
                    direction = Sort.Direction.DESC) Pageable pageable
    ) {

        return ApiResponse.<Page<ThoiGianThucHienResponse>>builder()
                .result(thoiGianThucHienService.getAllThoiGianThucHien(pageable))
                .build();

    }


    @PostMapping("/dot-bao-ve")
    public ApiResponse<DotBaoVeResponse> createDotBaoVe(@RequestBody DotBaoVeRequest dotBaoVeRequest) {

        return ApiResponse.<DotBaoVeResponse>builder()
                .result(dotBaoVeService.createDotBaoVe(dotBaoVeRequest))
                .build();

    }

    @GetMapping("/dot-bao-ve")
    public ApiResponse<Page<DotBaoVeResponse>> findAllDotBaoVe(
            @PageableDefault(
                    page = 0,
                    size = 10,
                    sort = "updatedAt",
                    direction = Sort.Direction.DESC) Pageable pageable
    ) {
        return ApiResponse.<Page<DotBaoVeResponse>>builder()
                .result(dotBaoVeService.findAllDotBaoVe(pageable))
                .build();
    }

    @PutMapping("/dot-bao-ve/{dotBaoVeId}")
    public ApiResponse<DotBaoVeResponse> updateDotBaoVe(@RequestBody DotBaoVeRequest request, @PathVariable("dotBaoVeId") Long dotBaoVeId) {

        return ApiResponse.<DotBaoVeResponse>builder()
                .result(dotBaoVeService.updateDotBaoVe(request, dotBaoVeId))
                .build();

    }

    @DeleteMapping("/dot-bao-ve/{dotBaoVeId}")
    public ApiResponse<String> deleteDotBaoVe(@PathVariable("dotBaoVeId") Long dotBaoVeId) {

        dotBaoVeService.deleteDotBaoVe(dotBaoVeId);
        return ApiResponse.<String>builder()
                .result("Delete dot bao ve successfully")
                .build();

    }

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
        return ApiResponse.<AddSinhVienToDotBaoVeResponse>builder()
                .result(dotBaoVeService.addSinhVienToDotBaoVe(request))
                .build();
    }
}