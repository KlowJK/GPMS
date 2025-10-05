package com.backend.gpms.features.topic.api;

import com.backend.gpms.common.util.ApiResponse;
import com.backend.gpms.features.topic.application.DeTaiService;
import com.backend.gpms.features.topic.application.DonHoanDoAnService;
import com.backend.gpms.features.topic.domain.TrangThaiDeTai;
import com.backend.gpms.features.topic.dto.request.DeTaiApprovalRequest;
import com.backend.gpms.features.topic.dto.request.DeTaiGiangVienHuongDanRequest;
import com.backend.gpms.features.topic.dto.request.DeTaiRequest;
import com.backend.gpms.features.topic.dto.request.DonHoanDoAnRequest;
import com.backend.gpms.features.topic.dto.response.DeTaiGiangVienHuongDanResponse;
import com.backend.gpms.features.topic.dto.response.DeTaiResponse;


import com.backend.gpms.features.topic.dto.response.DonHoanDoAnResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;


@Tag(name = "DeTai")
@RestController
@RequestMapping("/api/de-tai")
@AllArgsConstructor
public class DeTaiController {

    private final DeTaiService deTaiService;
    DonHoanDoAnService donHoanDoAnService;

    @PostMapping(value = "/dang-ky", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ApiResponse<DeTaiResponse> registerDeTai(@ModelAttribute @Valid DeTaiRequest request) {
        return ApiResponse.<DeTaiResponse>builder()
                .result(deTaiService.registerDeTai(request))
                .build();
    }

    @GetMapping("/xet-duyet")
    public ApiResponse<Page<DeTaiResponse>> listForGiangVien(
            @RequestParam(defaultValue = "CHO_DUYET") TrangThaiDeTai trangThai,
            @PageableDefault(page = 0, size = 10, sort = "updatedAt", direction = Sort.Direction.DESC)
            Pageable pageable) {

        return ApiResponse.<Page<DeTaiResponse>>builder()
                .result(deTaiService.getDeTaiByLecturerAndStatus(trangThai, pageable))
                .build();
    }

    @PutMapping("/xet-duyet/{deTaiId}")
    public ApiResponse<DeTaiResponse> approveDeTai(
            @PathVariable Long deTaiId,
            @RequestBody @Valid DeTaiApprovalRequest request) {

        return ApiResponse.<DeTaiResponse>builder()
                .result(deTaiService.approveDeTai(deTaiId, request))
                .build();
    }

    @GetMapping("/chi-tiet")
    public ApiResponse<DeTaiResponse> getMyDeTai() {
        return ApiResponse.<DeTaiResponse>builder()
                .result(deTaiService.getMyDeTai())
                .build();
    }

    @PostMapping("/gan-de-tai")
    public ApiResponse<DeTaiGiangVienHuongDanResponse> addGiangVienHuongDan(@RequestBody DeTaiGiangVienHuongDanRequest request) {
        return ApiResponse.<DeTaiGiangVienHuongDanResponse>builder()
                .result(deTaiService.addGiangVienHuongDan(request))
                .build();
    }

    // Sinh viên gửi đơn hoãn (lý do + file minh chứng optional)
    @PostMapping(value = "/sinh-vien/hoan-do-an", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ApiResponse<DonHoanDoAnResponse> createPostponeRequest(
            @ModelAttribute @Valid DonHoanDoAnRequest request) {
        return ApiResponse.<DonHoanDoAnResponse>builder()
                .result(donHoanDoAnService.createPostponeRequest(request))
                .build();
    }

    // Sinh viên xem danh sách đơn hoãn của chính mình
    @GetMapping("/danh-sach-sinh-vien/hoan-do-an")
    public ApiResponse<Page<DonHoanDoAnResponse>> getMyPostponeRequests(
            @PageableDefault(page = 0, size = 10, sort = "updatedAt", direction = Sort.Direction.DESC)
            Pageable pageable) {
        return ApiResponse.<Page<DonHoanDoAnResponse>>builder()
                .result(donHoanDoAnService.getMyPostponeRequests(pageable))
                .build();
    }
}