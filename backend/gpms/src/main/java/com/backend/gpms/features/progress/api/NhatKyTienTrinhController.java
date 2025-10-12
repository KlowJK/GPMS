package com.backend.gpms.features.progress.api;

import com.backend.gpms.common.util.ApiResponse;
import com.backend.gpms.features.progress.application.NhatKyTienTrinhService;
import com.backend.gpms.features.progress.dto.request.DuyetNhatKyRequest;
import com.backend.gpms.features.progress.dto.request.NhatKyTienTrinhRequest;
import com.backend.gpms.features.progress.dto.response.NhatKyTienTrinhResponse;
import com.backend.gpms.features.progress.dto.response.TuanResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;

import lombok.AllArgsConstructor;
import org.springdoc.core.annotations.ParameterObject;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.List;

@Tag(name = "NhatKyTienTrinh")
@RestController
@RequestMapping("/api/public")
@AllArgsConstructor
public class NhatKyTienTrinhController {

   
    private NhatKyTienTrinhService service;

    @GetMapping("/{deTaiId}/tuans")
    public ApiResponse<List<TuanResponse>> getTuanList(@PathVariable Long deTaiId) {
        return ApiResponse.success(service.getTuanList(deTaiId));
    }

    @GetMapping
    public ApiResponse<List<NhatKyTienTrinhResponse>> getNhatKyList() {
        return ApiResponse.success(service.getNhatKyList());
    }

    // Nộp không có tuan
    @PostMapping("/{deTaiId}")
    public ApiResponse<NhatKyTienTrinhResponse> nopNhatKy(
            @ParameterObject
            @ModelAttribute @Valid NhatKyTienTrinhRequest request){
        return ApiResponse.success(service.nopNhatKy(request));
    }

    @PutMapping("/{id}/duyet")
    public ApiResponse<NhatKyTienTrinhResponse> duyetNhatKy(
            @PathVariable Long id,
            @Valid @RequestBody DuyetNhatKyRequest request) {
        return ApiResponse.success(service.duyetNhatKy(id, request));
    }









}